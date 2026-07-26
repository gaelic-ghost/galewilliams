import Fluent
import Vapor

final class LeadNotification: Model, Content, @unchecked Sendable {
    static let schema = "lead_notifications"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "lead_submission_id")
    var lead: LeadSubmission

    @OptionalField(key: "recipient")
    var recipient: String?

    @Field(key: "status")
    var status: String

    @Field(key: "attempt_count")
    var attemptCount: Int

    @OptionalField(key: "provider_message_id")
    var providerMessageID: String?

    @OptionalField(key: "failure_reason")
    var failureReason: String?

    @OptionalField(key: "last_attempt_at")
    var lastAttemptAt: Date?

    @OptionalField(key: "sent_at")
    var sentAt: Date?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() {}

    init(leadID: UUID, recipient: String?, status: String, failureReason: String? = nil) {
        $lead.id = leadID
        self.recipient = recipient
        self.status = status
        attemptCount = 0
        self.failureReason = failureReason
    }
}

struct CreateLeadNotifications: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(LeadNotification.schema)
            .id()
            .field("lead_submission_id", .uuid, .required, .references(LeadSubmission.schema, "id", onDelete: .cascade))
            .field("recipient", .string)
            .field("status", .string, .required)
            .field("attempt_count", .int, .required)
            .field("provider_message_id", .string)
            .field("failure_reason", .string)
            .field("last_attempt_at", .datetime)
            .field("sent_at", .datetime)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(LeadNotification.schema).delete()
    }
}
