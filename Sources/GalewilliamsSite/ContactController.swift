import Fluent
import Queues
import Vapor

struct ContactController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get("contact", use: index)
        routes.post("contact", use: submit)
    }

    func index(request: Request) async throws -> Response {
        try await request.view.render("contact", ContactPage()).encodeResponse(for: request)
    }

    func submit(request: Request) async throws -> Response {
        let submittedIntake: ContactIntake
        do {
            submittedIntake = try request.content.decode(ContactIntake.self)
        } catch {
            return try await request.view.render("contact", ContactPage(formError: "Please complete every required contact field before sending your intake.")).encodeResponse(for: request)
        }
        if submittedIntake.isAutomatedSubmission {
            request.logger.warning("Discarded a contact submission that filled the hidden anti-automation field.")
            return try await request.view.render("contact", ContactPage(statusMessage: "Thanks. Your project details are saved and ready for review.")).encodeResponse(for: request)
        }

        do {
            try await ContactRateLimiter().enforce(for: request)
        } catch let error as AbortError where error.status == .tooManyRequests {
            throw error
        } catch {
            request.logger.warning("Contact rate limiting was unavailable, so the contact intake will still be persisted. Cause: \(error.localizedDescription)")
        }

        let intake: ContactIntake
        do {
            intake = try submittedIntake.validated()
        } catch let error as ContactIntakeValidationError {
            return try await request.view.render("contact", ContactPage(form: submittedIntake.formValues, fieldErrors: .init(error: error))).encodeResponse(for: request)
        }
        let submission = LeadSubmission(intake: intake)

        try await submission.save(on: request.db)
        request.logger.info("Saved contact intake \(submission.id?.uuidString ?? "without-id") with project type \(intake.projectType).")
        try await request.enqueueLeadNotification(for: submission)

        let message = "Thanks. Your project details are saved and ready for review."
        return try await request.view.render("contact", ContactPage(statusMessage: message)).encodeResponse(for: request)
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

    var formValues: ContactFormValues {
        .init(name: name, email: email, projectType: projectType, timeline: timeline, details: details)
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
            throw ContactIntakeValidationError(field: .name, message: "Enter your name so I know how to address your request.")
        }
        guard normalized.name.count <= 120 else {
            throw ContactIntakeValidationError(field: .name, message: "Use 120 characters or fewer for your name.")
        }
        guard normalized.email.contains("@") else {
            throw ContactIntakeValidationError(field: .email, message: "Enter a readable email address so I can reply.")
        }
        guard ProjectType(rawValue: normalized.projectType) != nil else {
            throw ContactIntakeValidationError(field: .projectType, message: "Choose the project type that best fits your request.")
        }
        guard normalized.timeline.isEmpty == false else {
            throw ContactIntakeValidationError(field: .timeline, message: "Share the timeline you are working toward.")
        }
        guard normalized.timeline.count <= 160 else {
            throw ContactIntakeValidationError(field: .timeline, message: "Use 160 characters or fewer for the timeline.")
        }
        guard normalized.details.count >= 20 else {
            throw ContactIntakeValidationError(field: .details, message: "Share at least 20 characters about what you need built.")
        }
        guard normalized.details.count <= 8000 else {
            throw ContactIntakeValidationError(field: .details, message: "Use 8,000 characters or fewer for the project details.")
        }

        return normalized
    }
}

struct ContactPage: Encodable {
    let chrome = SitePage.contact.chrome
    let intro = SitePage.contact.intro
    let notice: SiteNotice?
    let fieldErrors: ContactFormFieldErrors
    let form: ContactFormValues
    let projectTypes: [ProjectTypeOption]

    init(
        form: ContactFormValues = .init(),
        statusMessage: String? = nil,
        formError: String? = nil,
        fieldErrors: ContactFormFieldErrors = .init()
    ) {
        self.form = form
        notice = statusMessage.map(SiteNotice.status) ?? formError.map(SiteNotice.error)
        self.fieldErrors = fieldErrors
        projectTypes = ProjectType.options(selectedValue: form.projectType)
    }
}

struct ContactFormValues: Encodable {
    let name: String
    let email: String
    let projectType: String
    let timeline: String
    let details: String

    init(name: String = "", email: String = "", projectType: String = "", timeline: String = "", details: String = "") {
        self.name = name
        self.email = email
        self.projectType = projectType
        self.timeline = timeline
        self.details = details
    }
}

enum ProjectType: String, CaseIterable {
    case personalAgent = "personal-agent"
    case personalAutomation = "personal-automation"
    case pluginIntegration = "plugin-integration"
    case businessAutomation = "business-automation"
    case websiteWebApp = "website-webapp"
    case mobileApp = "mobile-app"
    case webMobileBundle = "web-mobile-bundle"

    var label: String {
        switch self {
            case .personalAgent:
                "Personal local AI agent"
            case .personalAutomation:
                "Personal automation workflow"
            case .pluginIntegration:
                "Plugin or tool integration"
            case .businessAutomation:
                "Business automation workflow"
            case .websiteWebApp:
                "Website or web app"
            case .mobileApp:
                "Mobile app"
            case .webMobileBundle:
                "Web plus mobile bundle"
        }
    }

    static func options(selectedValue: String) -> [ProjectTypeOption] {
        [
            .init(value: "", label: "Select a project type", isSelected: selectedValue.isEmpty, isPlaceholder: true),
        ] + allCases.map { type in
            .init(value: type.rawValue, label: type.label, isSelected: selectedValue == type.rawValue, isPlaceholder: false)
        }
    }
}

struct ProjectTypeOption: Encodable {
    let value: String
    let label: String
    let isSelected: Bool
    let isPlaceholder: Bool
}

enum ContactFormField: String {
    case name
    case email
    case projectType
    case timeline
    case details
}

struct ContactIntakeValidationError: Error {
    let field: ContactFormField
    let message: String
}

struct ContactFormFieldErrors: Encodable {
    let name: String?
    let email: String?
    let projectType: String?
    let timeline: String?
    let details: String?

    init(error: ContactIntakeValidationError? = nil) {
        name = error?.field == .name ? error?.message : nil
        email = error?.field == .email ? error?.message : nil
        projectType = error?.field == .projectType ? error?.message : nil
        timeline = error?.field == .timeline ? error?.message : nil
        details = error?.field == .details ? error?.message : nil
    }
}
