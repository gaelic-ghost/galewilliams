import Fluent
import Queues
import Vapor

struct ContactController: RouteCollection {
    private static let upworkURL = "https://www.upwork.com/freelancers/~01205e5fc3aa23ffcd"

    func boot(routes: RoutesBuilder) throws {
        routes.get("contact", use: index)
        routes.post("contact", use: submit)
    }

    func index(request: Request) async throws -> Response {
        try await renderPage(for: request)
    }

    func submit(request: Request) async throws -> Response {
        guard let security = request.application.contactFormSecurityConfiguration else {
            request.logger.warning("Rejected a secondary contact submission because contact-form security is not configured.")
            return try await renderPage(
                for: request,
                formError: "The secondary contact form is temporarily unavailable. You can still contact me through Upwork.",
                status: .serviceUnavailable
            )
        }

        let submittedForm: ContactIntakeForm
        do {
            submittedForm = try request.content.decode(ContactIntakeForm.self)
        } catch {
            request.logger.notice("Rejected a secondary contact submission with an unreadable form body.")
            return try await renderPage(
                for: request,
                formError: "Please complete every required contact field before sending your message.",
                status: .badRequest
            )
        }

        if submittedForm.isAutomatedSubmission {
            request.logger.notice("Discarded a secondary contact submission that filled the hidden anti-automation field.")
            return try await renderPage(for: request, statusMessage: "Thanks. Your message has been received.")
        }

        let submittedIntake = submittedForm.intake
        let clientAddress = request.contactClientAddress(using: security)

        do {
            try await ContactRateLimiter().enforce(for: request, email: submittedIntake.email, clientAddress: clientAddress)
        } catch let error as AbortError where error.status == .tooManyRequests {
            request.logger.notice("Rate-limited a secondary contact submission.")
            throw error
        } catch {
            request.logger.error("Rejected a secondary contact submission because Redis rate limiting was unavailable. Cause: \(error.localizedDescription)")
            return try await renderPage(
                for: request,
                form: submittedIntake.formValues,
                formError: "The secondary contact form is temporarily unavailable. Please try again later or contact me through Upwork.",
                status: .serviceUnavailable
            )
        }

        do {
            try ContactFormTimingProtection(secret: security.signingSecret).verify(
                submittedForm.formToken ?? "",
                minimumAge: request.application.environment == .testing ? 0 : 3
            )
        } catch {
            request.logger.notice("Rejected a secondary contact submission with a missing, invalid, too-new, or expired form token.")
            return try await renderPage(
                for: request,
                form: submittedIntake.formValues,
                formError: "This form session is no longer valid. Please review your message and try again.",
                status: .badRequest
            )
        }

        do {
            try await request.application.contactChallengeVerifier.verify(
                token: submittedForm.turnstileResponse ?? "",
                clientAddress: clientAddress,
                configuration: security,
                for: request
            )
        } catch let error as ContactFormProtectionError {
            switch error {
                case let .challengeRejected(codes):
                    request.logger.notice("Rejected a secondary contact submission after Turnstile validation. Codes: \(codes.joined(separator: ", "))")
                    return try await renderPage(
                        for: request,
                        form: submittedIntake.formValues,
                        formError: "The anti-spam check could not verify this submission. Please try again.",
                        status: .badRequest
                    )
                case let .challengeUnavailable(cause):
                    request.logger.error("Rejected a secondary contact submission because Turnstile validation was unavailable. Cause: \(cause)")
                    return try await renderPage(
                        for: request,
                        form: submittedIntake.formValues,
                        formError: "The anti-spam check is temporarily unavailable. Please try again later or contact me through Upwork.",
                        status: .serviceUnavailable
                    )
                case .invalidTimingToken:
                    throw error
            }
        }

        let intake: ContactIntake
        do {
            intake = try submittedIntake.validated()
        } catch let error as ContactIntakeValidationError {
            request.logger.notice("Rejected a secondary contact submission that failed field validation for \(error.field.rawValue).")
            return try await renderPage(
                for: request,
                form: submittedIntake.formValues,
                fieldErrors: .init(error: error),
                status: .unprocessableEntity
            )
        }

        let submission = LeadSubmission(intake: intake)
        try await submission.save(on: request.db)
        request.logger.info("Saved secondary contact inquiry \(submission.id?.uuidString ?? "without-id").")
        try await request.enqueueLeadNotification(for: submission)

        return try await renderPage(for: request, statusMessage: "Thanks. Your message is saved and ready for review.")
    }

    private func renderPage(
        for request: Request,
        form: ContactFormValues = .init(),
        statusMessage: String? = nil,
        formError: String? = nil,
        fieldErrors: ContactFormFieldErrors = .init(),
        status: HTTPStatus = .ok
    ) async throws -> Response {
        let security = request.application.contactFormSecurityConfiguration
        let formToken = security.map { ContactFormTimingProtection(secret: $0.signingSecret).issueToken() }
        let page = ContactPage(
            upworkURL: Self.upworkURL,
            turnstileSiteKey: security?.siteKey,
            formToken: formToken,
            form: form,
            statusMessage: statusMessage,
            formError: formError,
            fieldErrors: fieldErrors
        )
        let response = try await request.view.render("contact", page).encodeResponse(for: request)
        response.status = status
        return response
    }
}

private extension Request {
    func enqueueLeadNotification(for submission: LeadSubmission) async throws {
        guard let leadID = submission.id else {
            throw Abort(.internalServerError, reason: "Contact inquiry was saved but did not receive a lead identifier, so its notification record could not be created.")
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
            logger.warning("Contact inquiry \(leadID.uuidString) was saved, but no notification job was queued because the Amazon SES settings are incomplete. Cause: \(error.localizedDescription)")
            return
        }

        let notification = LeadNotification(leadID: leadID, recipient: configuration.recipient, status: "queued")
        try await notification.save(on: db)

        guard let notificationID = notification.id else {
            throw Abort(.internalServerError, reason: "Contact inquiry \(leadID.uuidString) was saved but its notification record did not receive an identifier, so the Redis job could not be queued.")
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
            logger.error("Contact inquiry \(leadID.uuidString) was saved, but its notification job was not queued in Redis. The inquiry can still be reviewed in admin. Cause: \(error.localizedDescription)")
        }
    }
}

struct ContactIntake: Content {
    static let inquiryType = "other-inquiry"
    static let unspecifiedTimeline = "Not provided"

    let name: String
    let email: String
    let details: String

    var formValues: ContactFormValues {
        .init(name: name, email: email, details: details)
    }

    func validated() throws -> ContactIntake {
        let normalized = ContactIntake(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            details: details.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        guard normalized.name.isEmpty == false else {
            throw ContactIntakeValidationError(field: .name, message: "Enter your name so I know how to address your message.")
        }
        guard normalized.name.count <= 120 else {
            throw ContactIntakeValidationError(field: .name, message: "Use 120 characters or fewer for your name.")
        }
        guard normalized.email.isPlausibleEmailAddress else {
            throw ContactIntakeValidationError(field: .email, message: "Enter a readable email address so I can reply.")
        }
        guard normalized.details.count >= 20 else {
            throw ContactIntakeValidationError(field: .details, message: "Share at least 20 characters about your inquiry.")
        }
        guard normalized.details.count <= 4000 else {
            throw ContactIntakeValidationError(field: .details, message: "Use 4,000 characters or fewer for your message.")
        }

        return normalized
    }
}

struct ContactIntakeForm: Content {
    let name: String?
    let email: String?
    let details: String?
    let website: String?
    let formToken: String?
    let turnstileResponse: String?

    enum CodingKeys: String, CodingKey {
        case name
        case email
        case details
        case website
        case formToken
        case turnstileResponse = "cf-turnstile-response"
    }

    var isAutomatedSubmission: Bool {
        website?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    var intake: ContactIntake {
        .init(name: name ?? "", email: email ?? "", details: details ?? "")
    }
}

struct ContactPage: Encodable {
    let chrome = SitePage.contact.chrome
    let intro = SitePage.contact.intro
    let upworkURL: String
    let turnstileSiteKey: String?
    let formToken: String?
    let isFormAvailable: Bool
    let notice: SiteNotice?
    let fieldErrors: ContactFormFieldErrors
    let form: ContactFormValues

    init(
        upworkURL: String = "https://www.upwork.com/freelancers/~01205e5fc3aa23ffcd",
        turnstileSiteKey: String? = nil,
        formToken: String? = nil,
        form: ContactFormValues = .init(),
        statusMessage: String? = nil,
        formError: String? = nil,
        fieldErrors: ContactFormFieldErrors = .init()
    ) {
        self.upworkURL = upworkURL
        self.turnstileSiteKey = turnstileSiteKey
        self.formToken = formToken
        isFormAvailable = turnstileSiteKey != nil && formToken != nil
        self.form = form
        notice = statusMessage.map(SiteNotice.status) ?? formError.map(SiteNotice.error)
        self.fieldErrors = fieldErrors
    }
}

struct ContactFormValues: Encodable {
    let name: String
    let email: String
    let details: String

    init(name: String = "", email: String = "", details: String = "") {
        self.name = name
        self.email = email
        self.details = details
    }
}

enum ContactFormField: String {
    case name
    case email
    case details
}

struct ContactIntakeValidationError: Error {
    let field: ContactFormField
    let message: String
}

struct ContactFormFieldErrors: Encodable {
    let name: String?
    let email: String?
    let details: String?

    init(error: ContactIntakeValidationError? = nil) {
        name = error?.field == .name ? error?.message : nil
        email = error?.field == .email ? error?.message : nil
        details = error?.field == .details ? error?.message : nil
    }
}

private extension String {
    var isPlausibleEmailAddress: Bool {
        guard count <= 254,
              rangeOfCharacter(from: .whitespacesAndNewlines) == nil,
              let separator = lastIndex(of: "@"),
              separator != startIndex,
              separator != index(before: endIndex)
        else {
            return false
        }

        let domain = self[index(after: separator)...]
        return domain.contains(".") && domain.first != "." && domain.last != "."
    }
}
