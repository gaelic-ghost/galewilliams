import Fluent
import Foundation
@testable import GalewilliamsSite
import Queues
import Testing
import Vapor
import VaporTesting

@Suite(.serialized)
struct GalewilliamsSiteTests {
    @Test("Primary pages expose expected paths")
    func primaryPagesExposeExpectedPaths() {
        #expect(SitePage.home.chrome.canonicalURL == "https://galewilliams.com")
        #expect(SitePage.services.chrome.canonicalURL == "https://galewilliams.com/services")
        #expect(SitePage.apps.chrome.robotsDirective == "noindex, nofollow")
        #expect(SitePage.about.intro.heading == "Hi, I’m Gale.")
        #expect(SitePage.contact.chrome.canonicalURL == "https://galewilliams.com/contact")
    }

    @Test("Primary navigation includes Apps")
    func primaryNavigationIncludesApps() {
        let items = SitePage.home.chrome.navItems
        let labels = items.map(\.label)

        #expect(labels == ["Home", "Services", "Apps", "About", "Contact"])
        #expect(items.first?.isCurrent == true)
        #expect(SitePage.contact.chrome.navItems.last?.isCurrent == true)
        #expect(OfferCatalog.personalServices.chrome.navItems.first(where: { $0.label == "Services" })?.isCurrent == true)
    }

    @Test("Contact page can carry a status message")
    func contactPageCanCarryStatusMessage() {
        let page = ContactPage(statusMessage: "Captured.")

        #expect(page.notice?.message == "Captured.")
        #expect(page.notice?.role == "status")
        #expect(page.chrome.title.contains("Contact"))
    }

    @Test("Contact intake validation trims values")
    func contactIntakeValidationTrimsValues() throws {
        let intake = ContactIntake(
            name: "  Gale  ",
            email: "  gale@example.com  ",
            projectType: "  plugin-integration  ",
            timeline: "  prototype in 2 weeks  ",
            details: "  Build a Codex plugin intake flow with enough detail.  ",
            website: nil
        )

        let validated = try intake.validated()

        #expect(validated.name == "Gale")
        #expect(validated.email == "gale@example.com")
        #expect(validated.projectType == "plugin-integration")
        #expect(validated.timeline == "prototype in 2 weeks")
        #expect(validated.details == "Build a Codex plugin intake flow with enough detail.")
    }

    @Test("Contact intake validation rejects incomplete details")
    func contactIntakeValidationRejectsIncompleteDetails() throws {
        let intake = ContactIntake(
            name: "Gale",
            email: "gale@example.com",
            projectType: "plugin-integration",
            timeline: "prototype in 2 weeks",
            details: "Too short.",
            website: nil
        )

        #expect(throws: ContactIntakeValidationError.self) {
            try intake.validated()
        }
    }

    @Test("Contact project types begin unselected and reject unknown values")
    func contactProjectTypesBeginUnselectedAndRejectUnknownValues() throws {
        let page = ContactPage()
        #expect(page.projectTypes.first?.value == "")
        #expect(page.projectTypes.first?.isSelected == true)
        #expect(page.projectTypes.first?.isPlaceholder == true)
        #expect(page.projectTypes.dropFirst().contains(where: \.isSelected) == false)

        let intake = ContactIntake(
            name: "Gale",
            email: "gale@example.com",
            projectType: "not-a-real-project-type",
            timeline: "prototype in 2 weeks",
            details: "Build a Codex plugin intake flow with enough detail.",
            website: nil
        )

        #expect(throws: ContactIntakeValidationError.self) {
            try intake.validated()
        }
    }

    @Test("Lead submissions start in new status")
    func leadSubmissionsStartInNewStatus() throws {
        let intake = try ContactIntake(
            name: "Gale",
            email: "gale@example.com",
            projectType: "plugin-integration",
            timeline: "prototype in 2 weeks",
            details: "Build a Codex plugin intake flow with enough detail.",
            website: nil
        ).validated()

        let submission = LeadSubmission(intake: intake)

        #expect(submission.name == "Gale")
        #expect(submission.email == "gale@example.com")
        #expect(submission.projectType == "plugin-integration")
        #expect(submission.status == "new")
    }

    @Test("Admin auth reports missing configuration")
    func adminAuthReportsMissingConfiguration() async throws {
        try await withAdminCredentials(username: nil, password: nil) {
            try await withApp { app in
                app.grouped(AdminAuthMiddleware()).get("admin-test") { _ in
                    "ok"
                }

                try await app.testing().test(.GET, "admin-test") { response async in
                    #expect(response.status == .serviceUnavailable)
                    #expect(response.body.string.contains("ADMIN_USERNAME"))
                }
            }
        }
    }

    @Test("Admin auth accepts configured basic credentials")
    func adminAuthAcceptsConfiguredBasicCredentials() async throws {
        try await withAdminCredentials(username: "gale", password: "secret") {
            try await withApp { app in
                app.grouped(AdminAuthMiddleware()).get("admin-test") { _ in
                    "ok"
                }

                var headers = HTTPHeaders()
                let token = Data("gale:secret".utf8).base64EncodedString()
                headers.add(name: .authorization, value: "Basic \(token)")

                try await app.testing().test(.GET, "admin-test", headers: headers) { response async in
                    #expect(response.status == .ok)
                    #expect(response.body.string == "ok")
                }
            }
        }
    }

    @Test("Admin auth rejects incorrect configured credentials")
    func adminAuthRejectsIncorrectConfiguredCredentials() async throws {
        try await withAdminCredentials(username: "gale", password: "secret") {
            try await withApp { app in
                app.grouped(AdminAuthMiddleware()).get("admin-test") { _ in
                    "ok"
                }

                var headers = HTTPHeaders()
                let token = Data("gale:not-secret".utf8).base64EncodedString()
                headers.add(name: .authorization, value: "Basic \(token)")

                try await app.testing().test(.GET, "admin-test", headers: headers) { response async in
                    #expect(response.status == .unauthorized)
                }
            }
        }
    }

    @Test("Admin CSRF tokens reject tampering")
    func adminCSRFTokenRejectsTampering() async throws {
        try await withAdminCSRFSecret {
            let protection = AdminCSRFProtection()
            let validToken = try protection.issueToken()
            try protection.verify(validToken)

            #expect(throws: Abort.self) {
                try protection.verify("\(validToken)tampered")
            }
        }
    }

    @Test("Public routes render successfully")
    func publicRoutesRenderSuccessfully() async throws {
        try await withApp { app in
            for path in ["/", "/services", "/services/personal", "/services/business", "/apps", "/about", "/contact", "/sitemap"] {
                try await app.testing().test(.GET, path) { response async in
                    #expect(response.status == .ok)
                    #expect(response.body.string.contains("Gale Williams"))
                    #expect(response.headers.first(name: "Content-Security-Policy")?.contains("default-src") == true)
                }
            }

            try await app.testing().test(.GET, "/") { response async in
                #expect(response.body.string.contains("<meta name=\"robots\" content=\"index, follow\">"))
                #expect(response.body.string.contains("<link rel=\"canonical\" href=\"https://galewilliams.com\">"))
                #expect(response.body.string.contains("https://galewilliams.com/images/galewilliams-social-card.png"))
                #expect(response.body.string.contains("href=\"#main-content\""))
                #expect(response.body.string.contains("aria-current=\"page\">Home"))
            }

            try await app.testing().test(.GET, "apps") { response async in
                #expect(response.body.string.contains("<meta name=\"robots\" content=\"noindex, nofollow\">"))
            }

            try await app.testing().test(.GET, "contact") { response async in
                #expect(response.body.string.contains("<option value=\"\" selected disabled>Select a project type</option>"))
                #expect(response.body.string.contains("aria-current=\"page\">Contact"))
            }

            try await app.testing().test(.GET, "sitemap.xml") { response async in
                #expect(response.status == .ok)
                #expect(response.headers.contentType?.description.contains("application/xml") == true)
                #expect(response.body.string.contains("https://galewilliams.com/services/personal"))
                #expect(response.body.string.contains("/admin") == false)
            }

            try await app.testing().test(.GET, "robots.txt") { response async in
                #expect(response.status == .ok)
                #expect(response.body.string.contains("Sitemap: https://galewilliams.com/sitemap.xml"))
            }
        }
    }

    @Test("Invalid contact intake renders inline validation feedback")
    func invalidContactIntakeRendersInlineValidationFeedback() async throws {
        try await withApp { app in
            let intake = ContactIntake(
                name: "Gale",
                email: "gale@example.com",
                projectType: "plugin-integration",
                timeline: "prototype in 2 weeks",
                details: "Too short.",
                website: nil
            )
            var headers = HTTPHeaders()
            var body = ByteBufferAllocator().buffer(capacity: 256)
            try URLEncodedFormEncoder().encode(intake, to: &body, headers: &headers)

            try await app.testing().test(.POST, "contact", headers: headers, body: body) { response async in
                #expect(response.status == .ok)
                #expect(response.body.string.contains("Share at least 20 characters about what you need built."))
                #expect(response.body.string.contains("gale@example.com"))
                #expect(response.body.string.contains("aria-invalid=\"true\" aria-describedby=\"details-error\""))
                #expect(response.body.string.contains("id=\"details-error\""))
                #expect(response.body.string.contains("<option value=\"plugin-integration\" selected>Plugin or tool integration</option>"))
            }
        }
    }

    @Test("Missing or forged project types render an accessible select error")
    func invalidProjectTypeRendersAccessibleSelectError() async throws {
        try await withApp { app in
            for projectType in ["", "forged-project-type"] {
                let intake = ContactIntake(
                    name: "Gale",
                    email: "gale@example.com",
                    projectType: projectType,
                    timeline: "prototype in 2 weeks",
                    details: "Build a Codex plugin intake flow with enough detail.",
                    website: nil
                )
                var headers = HTTPHeaders()
                var body = ByteBufferAllocator().buffer(capacity: 256)
                try URLEncodedFormEncoder().encode(intake, to: &body, headers: &headers)

                try await app.testing().test(.POST, "contact", headers: headers, body: body) { response async in
                    #expect(response.status == .ok)
                    #expect(response.body.string.contains("Choose the project type that best fits your request."))
                    #expect(response.body.string.contains("aria-invalid=\"true\" aria-describedby=\"project-type-error\""))
                    #expect(response.body.string.contains("id=\"project-type-error\""))
                }
            }
        }
    }

    @Test("Omitted contact controls render field errors and retain submitted values")
    func omittedContactControlsRenderFieldErrorsAndRetainSubmittedValues() async throws {
        let submissions: [(field: String, form: ContactIntakeForm, message: String)] = [
            ("name", .init(name: nil, email: "gale@example.com", projectType: "plugin-integration", timeline: "prototype in 2 weeks", details: "Build a Codex plugin intake flow with enough detail.", website: nil), "Enter your name so I know how to address your request."),
            ("email", .init(name: "Gale", email: nil, projectType: "plugin-integration", timeline: "prototype in 2 weeks", details: "Build a Codex plugin intake flow with enough detail.", website: nil), "Enter a readable email address so I can reply."),
            ("project type", .init(name: "Gale", email: "gale@example.com", projectType: nil, timeline: "prototype in 2 weeks", details: "Build a Codex plugin intake flow with enough detail.", website: nil), "Choose the project type that best fits your request."),
            ("timeline", .init(name: "Gale", email: "gale@example.com", projectType: "plugin-integration", timeline: nil, details: "Build a Codex plugin intake flow with enough detail.", website: nil), "Share the timeline you are working toward."),
            ("details", .init(name: "Gale", email: "gale@example.com", projectType: "plugin-integration", timeline: "prototype in 2 weeks", details: nil, website: nil), "Share at least 20 characters about what you need built."),
        ]

        try await withApp { app in
            for submission in submissions {
                var headers = HTTPHeaders()
                var body = ByteBufferAllocator().buffer(capacity: 256)
                try URLEncodedFormEncoder().encode(submission.form, to: &body, headers: &headers)

                try await app.testing().test(.POST, "contact", headers: headers, body: body) { response async in
                    #expect(response.status == .ok, "The omitted \(submission.field) field should return inline validation feedback.")
                    #expect(response.body.string.contains(submission.message))
                    #expect(response.body.string.contains("Gale") || submission.field == "name")
                    #expect(response.body.string.contains("gale@example.com") || submission.field == "email")
                    #expect(response.body.string.contains("<option value=\"plugin-integration\" selected>") || submission.field == "project type")
                    #expect(response.body.string.contains("prototype in 2 weeks") || submission.field == "timeline")
                    #expect(response.body.string.contains("Build a Codex plugin intake flow with enough detail.") || submission.field == "details")
                }
            }
        }
    }

    @Test("Contact form values remain escaped after validation")
    func contactFormValuesRemainEscapedAfterValidation() async throws {
        try await withApp { app in
            let intake = ContactIntake(
                name: "<script>alert(1)</script>",
                email: "gale@example.com",
                projectType: "plugin-integration",
                timeline: "prototype in 2 weeks",
                details: "Too short.",
                website: nil
            )
            var headers = HTTPHeaders()
            var body = ByteBufferAllocator().buffer(capacity: 256)
            try URLEncodedFormEncoder().encode(intake, to: &body, headers: &headers)

            try await app.testing().test(.POST, "contact", headers: headers, body: body) { response async in
                #expect(response.status == .ok)
                #expect(response.body.string.contains("&lt;script&gt;alert(1)&lt;/script&gt;"))
                #expect(response.body.string.contains("<script>alert(1)</script>") == false)
            }
        }
    }

    @Test(
        "Database integration persists intake, queues notification, and reviews the lead",
        .enabled(if: Environment.get("RUN_DATABASE_INTEGRATION_TESTS") == "true")
    )
    func databaseIntegrationPersistsIntakeQueuesNotificationAndReviewsLead() async throws {
        try await withLeadNotificationEnvironment {
            try await withAdminCSRFSecret {
                try await withAdminCredentials(username: "gale", password: "secret") {
                    try await withApp { app in
                        try await app.autoMigrate()

                        try await app.testing().test(.GET, "api/ready") { response async in
                            #expect(response.status == .ok)
                            #expect(response.body.string.contains("ready"))
                        }

                        let intake = ContactIntake(
                            name: "Integration Lead",
                            email: "integration-lead-\(UUID().uuidString)@example.com",
                            projectType: "plugin-integration",
                            timeline: "prototype in 2 weeks",
                            details: "Build a durable integration-test lead workflow with notification tracking.",
                            website: nil
                        )
                        var headers = HTTPHeaders()
                        var body = ByteBufferAllocator().buffer(capacity: 256)
                        try URLEncodedFormEncoder().encode(intake, to: &body, headers: &headers)

                        try await app.testing().test(.POST, "contact", headers: headers, body: body) { response async in
                            #expect(response.status == .ok)
                            #expect(response.body.string.contains("saved and ready for review"))
                        }

                        guard let lead = try await LeadSubmission.query(on: app.db)
                            .filter(\LeadSubmission.$email == intake.email)
                            .first(), let leadID = lead.id
                        else {
                            Issue.record("Database integration contact submission did not persist a lead record for the submitted email address.")
                            return
                        }

                        let notifications = try await LeadNotification.query(on: app.db)
                            .filter(\LeadNotification.$lead.$id == leadID)
                            .all()
                        #expect(notifications.count == 1)
                        #expect(notifications.first?.status == "queued")
                        #expect(notifications.first?.recipient == "owner@example.com")

                        guard let notificationID = notifications.first?.id else {
                            Issue.record("Database integration contact submission persisted a notification without an identifier for the worker job.")
                            return
                        }

                        let sender = RecordingLeadNotificationEmailSender()
                        app.leadNotificationEmailSender = sender
                        let context = QueueContext(
                            queueName: LeadNotificationJob.queue,
                            configuration: app.queues.configuration,
                            application: app,
                            logger: app.logger,
                            on: app.eventLoopGroup.any()
                        )
                        try await LeadNotificationJob().dequeue(context, .init(notificationID: notificationID))
                        try await LeadNotificationJob().dequeue(context, .init(notificationID: notificationID))

                        let deliveredNotification = try await LeadNotification.find(notificationID, on: app.db)
                        #expect(deliveredNotification?.status == "sent")
                        #expect(deliveredNotification?.attemptCount == 1)
                        #expect(deliveredNotification?.providerMessageID == "test-message-id")
                        #expect(await sender.sentLeadIDs() == [leadID])

                        var adminHeaders = HTTPHeaders()
                        let token = Data("gale:secret".utf8).base64EncodedString()
                        adminHeaders.add(name: .authorization, value: "Basic \(token)")

                        try await app.testing().test(.GET, "admin/leads", headers: adminHeaders) { response async in
                            #expect(response.status == .ok)
                            #expect(response.body.string.contains(intake.email))
                        }
                        try await app.testing().test(.GET, "admin/leads/\(leadID.uuidString)", headers: adminHeaders) { response async in
                            #expect(response.status == .ok)
                            #expect(response.body.string.contains("Notification Delivery"))
                            #expect(response.body.string.contains("test-message-id") == false)
                            #expect(response.body.string.contains("sent"))
                        }
                        let review = try ReviewSubmission(csrfToken: AdminCSRFProtection().issueToken())
                        var reviewBody = ByteBufferAllocator().buffer(capacity: 256)
                        try URLEncodedFormEncoder().encode(review, to: &reviewBody, headers: &adminHeaders)
                        try await app.testing().test(.POST, "admin/leads/\(leadID.uuidString)/review", headers: adminHeaders, body: reviewBody) { response async in
                            #expect(response.status == .seeOther)
                        }

                        let reviewedLead = try await LeadSubmission.find(leadID, on: app.db)
                        #expect(reviewedLead?.status == "reviewed")
                        #expect(reviewedLead?.reviewedAt != nil)

                        let strandedNotification = LeadNotification(
                            leadID: leadID,
                            recipient: nil,
                            status: "queue_failed",
                            failureReason: "Redis was temporarily unavailable while this notification was first queued."
                        )
                        try await strandedNotification.save(on: app.db)
                        guard let strandedNotificationID = strandedNotification.id else {
                            Issue.record("Integration test persisted a stranded notification without an identifier for reconciliation.")
                            return
                        }

                        try await LeadNotificationReconciliationJob().run(context: context)

                        let requeuedNotification = try await LeadNotification.find(strandedNotificationID, on: app.db)
                        #expect(requeuedNotification?.status == "queued")
                        #expect(requeuedNotification?.recipient == "owner@example.com")
                        #expect(requeuedNotification?.failureReason == nil)

                        try await LeadNotificationJob().dequeue(context, .init(notificationID: strandedNotificationID))
                        let reconciledNotification = try await LeadNotification.find(strandedNotificationID, on: app.db)
                        #expect(reconciledNotification?.status == "sent")
                        #expect(await sender.sentLeadIDs() == [leadID, leadID])
                    }
                }
            }
        }
    }

    private func withApp(_ test: (Application) async throws -> Void) async throws {
        let app = try await Application.make(.testing)
        do {
            try configure(app)
            try await test(app)
            try await app.asyncShutdown()
        } catch {
            try? await app.asyncShutdown()
            throw error
        }
    }

    private func withAdminCredentials(
        username: String?,
        password: String?,
        _ test: () async throws -> Void
    ) async throws {
        let previousUsername = Environment.get("ADMIN_USERNAME")
        let previousPassword = Environment.get("ADMIN_PASSWORD")

        setEnvironmentValue(username, for: "ADMIN_USERNAME")
        setEnvironmentValue(password, for: "ADMIN_PASSWORD")
        defer {
            setEnvironmentValue(previousUsername, for: "ADMIN_USERNAME")
            setEnvironmentValue(previousPassword, for: "ADMIN_PASSWORD")
        }

        try await test()
    }

    private func withAdminCSRFSecret(_ test: () async throws -> Void) async throws {
        let previousSecret = Environment.get("ADMIN_CSRF_SECRET")
        setEnvironmentValue("0123456789abcdef0123456789abcdef", for: "ADMIN_CSRF_SECRET")
        defer { setEnvironmentValue(previousSecret, for: "ADMIN_CSRF_SECRET") }
        try await test()
    }

    private func withLeadNotificationEnvironment(_ test: () async throws -> Void) async throws {
        let values = [
            "AWS_REGION": "us-east-1",
            "SES_FROM_EMAIL": "sender@example.com",
            "LEAD_NOTIFICATION_TO_EMAIL": "owner@example.com",
        ]
        let previousValues = values.keys.reduce(into: [String: String?]()) { values, name in
            values[name] = Environment.get(name)
        }

        for (name, value) in values {
            setEnvironmentValue(value, for: name)
        }
        defer {
            for (name, value) in previousValues {
                setEnvironmentValue(value, for: name)
            }
        }

        try await test()
    }

    private func setEnvironmentValue(_ value: String?, for name: String) {
        if let value {
            setenv(name, value, 1)
        } else {
            unsetenv(name)
        }
    }
}

private struct ReviewSubmission: Content {
    let csrfToken: String
}

private actor RecordingLeadNotificationEmailSender: LeadNotificationEmailSending {
    private var ids: [UUID] = []

    func send(lead: LeadSubmission) async throws -> String? {
        guard let id = lead.id else {
            throw Abort(.internalServerError, reason: "Integration-test email sender received a lead without a database identifier.")
        }

        ids.append(id)
        return "test-message-id"
    }

    func sentLeadIDs() -> [UUID] {
        ids
    }
}
