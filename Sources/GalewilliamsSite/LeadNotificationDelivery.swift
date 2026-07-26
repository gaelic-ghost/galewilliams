import AWSSES
import Fluent
import Foundation
import Queues
import Vapor

struct LeadNotificationConfiguration {
    let awsRegion: String
    let sender: String
    let recipient: String

    static func load() throws -> LeadNotificationConfiguration {
        let requiredValues = [
            ("AWS_REGION", Environment.get("AWS_REGION")),
            ("SES_FROM_EMAIL", Environment.get("SES_FROM_EMAIL")),
            ("LEAD_NOTIFICATION_TO_EMAIL", Environment.get("LEAD_NOTIFICATION_TO_EMAIL")),
        ]
        let missingNames = requiredValues.compactMap { name, value in
            value?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? nil : name
        }

        guard missingNames.isEmpty else {
            throw Abort(
                .serviceUnavailable,
                reason: "Lead notification delivery needs \(missingNames.joined(separator: ", ")) configured before the notifications worker can send email through Amazon SES."
            )
        }

        return .init(
            awsRegion: requiredValues[0].1!.trimmingCharacters(in: .whitespacesAndNewlines),
            sender: requiredValues[1].1!.trimmingCharacters(in: .whitespacesAndNewlines),
            recipient: requiredValues[2].1!.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
}

struct LeadNotificationJob: AsyncJob {
    struct Payload: Content {
        let notificationID: UUID
    }

    static let queue = QueueName(string: "notifications", workerCount: 1)

    func dequeue(_ context: QueueContext, _ payload: Payload) async throws {
        guard let notification = try await LeadNotification.find(payload.notificationID, on: context.application.db) else {
            context.logger.warning("Lead notification worker skipped notification \(payload.notificationID) because its database record no longer exists.")
            return
        }
        guard notification.status != "sent" else {
            context.logger.info("Lead notification worker skipped notification \(payload.notificationID) because Amazon SES already accepted it.")
            return
        }

        do {
            guard let lead = try await LeadSubmission.find(notification.$lead.id, on: context.application.db) else {
                throw Abort(.notFound, reason: "Lead notification \(payload.notificationID) cannot be delivered because its lead submission no longer exists.")
            }

            notification.status = "sending"
            notification.attemptCount += 1
            notification.lastAttemptAt = Date()
            notification.failureReason = nil
            try await notification.save(on: context.application.db)

            let messageID = try await context.application.leadNotificationEmailSender.send(lead: lead)
            notification.status = "sent"
            notification.providerMessageID = messageID
            notification.sentAt = Date()
            try await notification.save(on: context.application.db)
            context.logger.info("Lead notification \(payload.notificationID) was accepted by Amazon SES after \(notification.attemptCount) delivery attempt(s).")
        } catch {
            notification.status = "failed"
            notification.failureReason = error.localizedDescription
            notification.lastAttemptAt = Date()
            try? await notification.save(on: context.application.db)
            context.logger.error("Lead notification \(payload.notificationID) was not accepted by Amazon SES. The worker will retry while attempts remain. Cause: \(error.localizedDescription)")
            throw error
        }
    }

    func nextRetryIn(attempt: Int) -> Int {
        min(60 * attempt, 300)
    }
}

struct LeadNotificationReconciliationJob: AsyncScheduledJob {
    func run(context: QueueContext) async throws {
        let configuration: LeadNotificationConfiguration
        do {
            configuration = try LeadNotificationConfiguration.load()
        } catch {
            context.logger.warning("Lead notification reconciliation skipped because Amazon SES settings are incomplete. Persisted notifications will be retried after AWS_REGION, SES_FROM_EMAIL, and LEAD_NOTIFICATION_TO_EMAIL are configured. Cause: \(error.localizedDescription)")
            return
        }

        let notifications = try await LeadNotification.query(on: context.application.db)
            .group(.or) { group in
                group.filter(\.$status == "configuration_missing")
                group.filter(\.$status == "queue_failed")
            }
            .all()

        for notification in notifications {
            guard let notificationID = notification.id else {
                context.logger.warning("Lead notification reconciliation skipped a persisted notification without an identifier.")
                continue
            }

            notification.recipient = configuration.recipient
            notification.status = "queued"
            notification.failureReason = nil
            try await notification.save(on: context.application.db)

            do {
                try await context.application.queues.queue(LeadNotificationJob.queue).dispatch(
                    LeadNotificationJob.self,
                    .init(notificationID: notificationID),
                    maxRetryCount: 4
                )
                context.logger.info("Lead notification reconciliation returned notification \(notificationID) to the Redis queue.")
            } catch {
                notification.status = "queue_failed"
                notification.failureReason = error.localizedDescription
                try? await notification.save(on: context.application.db)
                context.logger.error("Lead notification reconciliation could not return notification \(notificationID) to Redis. The notification remains persisted for a later retry. Cause: \(error.localizedDescription)")
            }
        }
    }
}

protocol LeadNotificationEmailSending: Sendable {
    func send(lead: LeadSubmission) async throws -> String?
}

struct SESLeadNotificationEmailSender: LeadNotificationEmailSending {
    func send(lead: LeadSubmission) async throws -> String? {
        let configuration = try LeadNotificationConfiguration.load()
        let client = try SESClient(region: configuration.awsRegion)
        let response = try await client.sendEmail(
            input: .init(
                destination: .init(toAddresses: [configuration.recipient]),
                message: .init(
                    body: .init(text: .init(charset: "UTF-8", data: body(for: lead))),
                    subject: .init(charset: "UTF-8", data: "New galewilliams.com lead: \(lead.projectType)")
                ),
                source: configuration.sender
            )
        )
        return response.messageId
    }

    private func body(for lead: LeadSubmission) -> String {
        """
        A new galewilliams.com lead is ready for review.

        Name: \(lead.name)
        Email: \(lead.email)
        Project type: \(lead.projectType)
        Timeline: \(lead.timeline)

        Details:
        \(lead.details)
        """
    }
}

private struct LeadNotificationEmailSenderKey: StorageKey {
    typealias Value = any LeadNotificationEmailSending
}

extension Application {
    var leadNotificationEmailSender: any LeadNotificationEmailSending {
        get {
            guard let sender = storage[LeadNotificationEmailSenderKey.self] else {
                fatalError("Lead notification email sender is unavailable because configureLeadNotifications(_:) did not register the SES transport.")
            }

            return sender
        }
        set {
            storage[LeadNotificationEmailSenderKey.self] = newValue
        }
    }
}
