import Crypto
import Foundation
import Vapor

struct ContactFormSecurityConfiguration {
    static let action = "contact"

    let siteKey: String
    let secretKey: String
    let signingSecret: String
    let expectedHostname: String
    let clientIPHeader: String?

    static func load() throws -> ContactFormSecurityConfiguration {
        let siteKey = Environment.get("TURNSTILE_SITE_KEY")?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        let secretKey = Environment.get("TURNSTILE_SECRET_KEY")?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        let signingSecret = Environment.get("CONTACT_FORM_SECRET")?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        let requiredValues = [
            "TURNSTILE_SITE_KEY": siteKey,
            "TURNSTILE_SECRET_KEY": secretKey,
            "CONTACT_FORM_SECRET": signingSecret,
        ]
        let missing = requiredValues.compactMap { name, value in value == nil ? name : nil }
        guard missing.isEmpty else {
            throw Abort(.serviceUnavailable, reason: "Secondary contact intake requires configuration for: \(missing.sorted().joined(separator: ", ")).")
        }
        guard let siteKey, let secretKey, let signingSecret else {
            throw Abort(.serviceUnavailable, reason: "Secondary contact intake security configuration could not be loaded.")
        }
        guard signingSecret.utf8.count >= 32 else {
            throw Abort(.serviceUnavailable, reason: "CONTACT_FORM_SECRET must contain at least 32 characters.")
        }

        let hostname = (Environment.get("TURNSTILE_EXPECTED_HOSTNAME") ?? Environment.get("SITE_DOMAIN") ?? "galewilliams.com")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard hostname.isEmpty == false else {
            throw Abort(.serviceUnavailable, reason: "TURNSTILE_EXPECTED_HOSTNAME or SITE_DOMAIN must name the hostname allowed to submit the secondary contact form.")
        }

        return .init(
            siteKey: siteKey,
            secretKey: secretKey,
            signingSecret: signingSecret,
            expectedHostname: hostname,
            clientIPHeader: Environment.get("CONTACT_CLIENT_IP_HEADER")?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        )
    }
}

struct ContactFormTimingProtection {
    private static let minimumAge: TimeInterval = 3
    private static let maximumAge: TimeInterval = 2 * 60 * 60

    let secret: String

    func issueToken(now: Date = .now) -> String {
        let timestamp = String(Int(now.timeIntervalSince1970))
        let authenticationCode = HMAC<SHA256>.authenticationCode(
            for: Data(timestamp.utf8),
            using: SymmetricKey(data: Data(secret.utf8))
        )
        return "\(timestamp).\(Data(authenticationCode).base64EncodedString())"
    }

    func verify(_ token: String, now: Date = .now, minimumAge: TimeInterval = Self.minimumAge) throws {
        let components = token.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)
        guard components.count == 2,
              let issuedTimestamp = TimeInterval(components[0]),
              let suppliedCode = Data(base64Encoded: String(components[1]))
        else {
            throw ContactFormProtectionError.invalidTimingToken
        }

        let timestamp = String(components[0])
        let key = SymmetricKey(data: Data(secret.utf8))
        guard HMAC<SHA256>.isValidAuthenticationCode(suppliedCode, authenticating: Data(timestamp.utf8), using: key) else {
            throw ContactFormProtectionError.invalidTimingToken
        }

        let age = now.timeIntervalSince1970 - issuedTimestamp
        guard age >= minimumAge, age <= Self.maximumAge else {
            throw ContactFormProtectionError.invalidTimingToken
        }
    }
}

protocol ContactChallengeVerifying: Sendable {
    func verify(token: String, clientAddress: String?, configuration: ContactFormSecurityConfiguration, for request: Request) async throws
}

struct CloudflareTurnstileVerifier: ContactChallengeVerifying {
    private static let siteverifyURL = URI(string: "https://challenges.cloudflare.com/turnstile/v0/siteverify")

    func verify(token: String, clientAddress: String?, configuration: ContactFormSecurityConfiguration, for request: Request) async throws {
        guard token.isEmpty == false, token.utf8.count <= 2048 else {
            throw ContactFormProtectionError.challengeRejected(codes: ["missing-or-oversized-token"])
        }

        let response: ClientResponse
        do {
            let verificationRequest = TurnstileVerificationRequest(
                secret: configuration.secretKey,
                response: token,
                remoteIP: clientAddress
            )
            response = try await request.client.post(Self.siteverifyURL) { clientRequest in
                clientRequest.timeout = .seconds(5)
                try clientRequest.content.encode(verificationRequest)
            }
        } catch {
            throw ContactFormProtectionError.challengeUnavailable(cause: error.localizedDescription)
        }

        guard response.status == .ok else {
            throw ContactFormProtectionError.challengeUnavailable(cause: "Siteverify returned HTTP \(response.status.code).")
        }

        let result: TurnstileVerificationResponse
        do {
            result = try response.content.decode(TurnstileVerificationResponse.self)
        } catch {
            throw ContactFormProtectionError.challengeUnavailable(cause: "Siteverify returned an unreadable response: \(error.localizedDescription)")
        }

        guard result.success,
              result.action == ContactFormSecurityConfiguration.action,
              result.hostname == configuration.expectedHostname
        else {
            throw ContactFormProtectionError.challengeRejected(codes: result.errorCodes ?? ["action-or-hostname-mismatch"])
        }
    }
}

enum ContactFormProtectionError: Error {
    case invalidTimingToken
    case challengeRejected(codes: [String])
    case challengeUnavailable(cause: String)
}

private struct TurnstileVerificationRequest: Content {
    let secret: String
    let response: String
    let remoteIP: String?

    enum CodingKeys: String, CodingKey {
        case secret
        case response
        case remoteIP = "remoteip"
    }
}

private struct TurnstileVerificationResponse: Content {
    let success: Bool
    let hostname: String?
    let action: String?
    let errorCodes: [String]?

    enum CodingKeys: String, CodingKey {
        case success
        case hostname
        case action
        case errorCodes = "error-codes"
    }
}

private struct ContactFormSecurityConfigurationKey: StorageKey {
    typealias Value = ContactFormSecurityConfiguration
}

private struct ContactChallengeVerifierKey: StorageKey {
    typealias Value = any ContactChallengeVerifying
}

extension Application {
    var contactFormSecurityConfiguration: ContactFormSecurityConfiguration? {
        get { storage[ContactFormSecurityConfigurationKey.self] }
        set { storage[ContactFormSecurityConfigurationKey.self] = newValue }
    }

    var contactChallengeVerifier: any ContactChallengeVerifying {
        get { storage[ContactChallengeVerifierKey.self] ?? CloudflareTurnstileVerifier() }
        set { storage[ContactChallengeVerifierKey.self] = newValue }
    }
}

extension Request {
    func contactClientAddress(using configuration: ContactFormSecurityConfiguration) -> String? {
        if let header = configuration.clientIPHeader,
           let address = headers.first(name: header)?.split(separator: ",").first?.trimmingCharacters(in: .whitespacesAndNewlines),
           address.isEmpty == false {
            return address
        }
        return remoteAddress?.ipAddress
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
