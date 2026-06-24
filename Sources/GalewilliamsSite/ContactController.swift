import Fluent
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
        let intake = try request.content.decode(ContactIntake.self).validated()
        let submission = LeadSubmission(intake: intake)

        try await submission.save(on: request.db)
        request.logger.info("Saved contact intake \(submission.id?.uuidString ?? "without-id") for \(intake.email) about \(intake.projectType).")

        let message = "Thanks. Your project details are saved and ready for review."
        return try await request.view.render("contact", SitePage.contact(statusMessage: message)).encodeResponse(for: request)
    }
}

struct ContactIntake: Content {
    let name: String
    let email: String
    let projectType: String
    let timeline: String
    let details: String

    func validated() throws -> ContactIntake {
        let normalized = ContactIntake(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            projectType: projectType.trimmingCharacters(in: .whitespacesAndNewlines),
            timeline: timeline.trimmingCharacters(in: .whitespacesAndNewlines),
            details: details.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        guard normalized.name.isEmpty == false else {
            throw Abort(.badRequest, reason: "Contact intake is missing a name.")
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
        guard normalized.details.count >= 20 else {
            throw Abort(.badRequest, reason: "Contact intake details need at least 20 characters.")
        }

        return normalized
    }
}
