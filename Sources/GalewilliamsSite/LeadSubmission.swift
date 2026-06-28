import Fluent
import Vapor

final class LeadSubmission: Model, Content, @unchecked Sendable {
    static let schema = "lead_submissions"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "email")
    var email: String

    @Field(key: "project_type")
    var projectType: String

    @Field(key: "timeline")
    var timeline: String

    @Field(key: "details")
    var details: String

    @Field(key: "status")
    var status: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @OptionalField(key: "reviewed_at")
    var reviewedAt: Date?

    init() {}

    init(intake: ContactIntake) {
        name = intake.name
        email = intake.email
        projectType = intake.projectType
        timeline = intake.timeline
        details = intake.details
        status = "new"
    }
}

struct CreateLeadSubmissions: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(LeadSubmission.schema)
            .id()
            .field("name", .string, .required)
            .field("email", .string, .required)
            .field("project_type", .string, .required)
            .field("timeline", .string, .required)
            .field("details", .string, .required)
            .field("status", .string, .required)
            .field("created_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(LeadSubmission.schema).delete()
    }
}

struct AddLeadSubmissionReviewFields: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(LeadSubmission.schema)
            .field("reviewed_at", .datetime)
            .update()
    }

    func revert(on database: Database) async throws {
        try await database.schema(LeadSubmission.schema)
            .deleteField("reviewed_at")
            .update()
    }
}
