import Fluent
import Queues
import Vapor

struct ContactController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get("contact", use: index)
        routes.post("contact", use: submit)
    }

    func index(request: Request) async throws -> Response {
        try await request.view.render("contact", SitePage.contact()).encodeResponse(for: request)
    }

    func submit(request: Request) async throws -> Response {
        let submittedIntake = try request.content.decode(ContactIntake.self)
        if submittedIntake.isAutomatedSubmission {
            request.logger.warning("Discarded a contact submission that filled the hidden anti-automation field.")
            return try await request.view.render("contact", SitePage.contact(statusMessage: "Thanks. Your project details are saved and ready for review.")).encodeResponse(for: request)
        }

        do {
            try await ContactRateLimiter().enforce(for: request)
        } catch let error as AbortError where error.status == .tooManyRequests {
            throw error
        } catch {
            request.logger.warning("Contact rate limiting was unavailable, so the contact intake will still be persisted. Cause: \(error.localizedDescription)")
        }

        let intake = try submittedIntake.validated()
        let submission = LeadSubmission(intake: intake)

        try await submission.save(on: request.db)
        request.logger.info("Saved contact intake \(submission.id?.uuidString ?? "without-id") with project type \(intake.projectType).")
        try await request.enqueueLeadNotification(for: submission)

        let message = "Thanks. Your project details are saved and ready for review."
        return try await request.view.render("contact", SitePage.contact(statusMessage: message)).encodeResponse(for: request)
    }
}

private extension Request {
    func enqueueLeadNotification(for submission: LeadSubmission) async throws {
        guard let leadID = submission.id else {
            throw Abort(.internalServerError, reason: "Contact intake was saved but did not receive a lead identifier, so its notification record could not be created.")
        }

        let configuration: LeadNotificationConfiguration
        do {
            configuration = try LeadNotificationConfiguration.load()
        } catch {
            let notification = LeadNotification(
                leadID: leadID,
                recipient: nil,
                status: "configuration_missing",
                failureReason: error.localizedDescription
            )
            try await notification.save(on: db)
            logger.warning("Contact intake \(leadID.uuidString) was saved, but no notification job was queued because the Amazon SES settings are incomplete. Cause: \(error.localizedDescription)")
            return
        }

        let notification = LeadNotification(leadID: leadID, recipient: configuration.recipient, status: "queued")
        try await notification.save(on: db)

        guard let notificationID = notification.id else {
            throw Abort(.internalServerError, reason: "Contact intake \(leadID.uuidString) was saved but its notification record did not receive an identifier, so the Redis job could not be queued.")
        }

        do {
            try await application.queues.queue(LeadNotificationJob.queue).dispatch(
                LeadNotificationJob.self,
                .init(notificationID: notificationID),
                maxRetryCount: 4
            )
        } catch {
            notification.status = "queue_failed"
            notification.failureReason = error.localizedDescription
            try? await notification.save(on: db)
            logger.error("Contact intake \(leadID.uuidString) was saved, but its notification job was not queued in Redis. The lead can still be reviewed in admin. Cause: \(error.localizedDescription)")
        }
    }
}

struct ContactIntake: Content {
    let name: String
    let email: String
    let projectType: String
    let timeline: String
    let details: String
    var website: String?

    var isAutomatedSubmission: Bool {
        website?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    func validated() throws -> ContactIntake {
        let normalized = ContactIntake(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            projectType: projectType.trimmingCharacters(in: .whitespacesAndNewlines),
            timeline: timeline.trimmingCharacters(in: .whitespacesAndNewlines),
            details: details.trimmingCharacters(in: .whitespacesAndNewlines),
            website: website
        )

        guard normalized.name.isEmpty == false else {
            throw Abort(.badRequest, reason: "Contact intake is missing a name.")
        }
        guard normalized.name.count <= 120 else {
            throw Abort(.badRequest, reason: "Contact intake names must be 120 characters or fewer.")
        }
        guard normalized.email.contains("@") else {
            throw Abort(.badRequest, reason: "Contact intake needs a readable email address.")
        }
        guard normalized.projectType.isEmpty == false else {
            throw Abort(.badRequest, reason: "Contact intake is missing a project type.")
        }
        guard normalized.timeline.isEmpty == false else {
            throw Abort(.badRequest, reason: "Contact intake is missing a timeline.")
        }
        guard normalized.timeline.count <= 160 else {
            throw Abort(.badRequest, reason: "Contact intake timelines must be 160 characters or fewer.")
        }
        guard normalized.details.count >= 20 else {
            throw Abort(.badRequest, reason: "Contact intake details need at least 20 characters.")
        }
        guard normalized.details.count <= 8000 else {
            throw Abort(.badRequest, reason: "Contact intake details must be 8,000 characters or fewer.")
        }

        return normalized
    }
}
