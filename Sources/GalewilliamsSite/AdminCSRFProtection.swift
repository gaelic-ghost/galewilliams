import Crypto
import Foundation
import Vapor

struct AdminCSRFProtection {
    private static let maximumTokenAge: TimeInterval = 15 * 60

    func issueToken() throws -> String {
        let secret = try loadSecret()
        let payload = "\(Int(Date().timeIntervalSince1970)).\(UUID().uuidString)"
        let signature = signature(for: payload, secret: secret)
        return "\(payload).\(signature)"
    }

    func verify(_ token: String?) throws {
        guard let token else {
            throw Abort(.forbidden, reason: "Admin review requires a valid form security token. Reload the lead page and try again.")
        }

        let components = token.split(separator: ".", maxSplits: 2, omittingEmptySubsequences: false)
        guard components.count == 3,
              let issuedAt = TimeInterval(components[0])
        else {
            throw Abort(.forbidden, reason: "Admin review received an unreadable form security token. Reload the lead page and try again.")
        }

        let now = Date().timeIntervalSince1970
        guard issuedAt <= now, now - issuedAt <= Self.maximumTokenAge else {
            throw Abort(.forbidden, reason: "Admin review form security token expired. Reload the lead page and try again.")
        }

        let payload = "\(components[0]).\(components[1])"
        let expected = signature(for: payload, secret: try loadSecret())
        guard constantTimeEquals(expected, String(components[2])) else {
            throw Abort(.forbidden, reason: "Admin review form security token does not match this site. Reload the lead page and try again.")
        }
    }

    private func loadSecret() throws -> String {
        guard let secret = Environment.get("ADMIN_CSRF_SECRET")?.trimmingCharacters(in: .whitespacesAndNewlines), secret.count >= 32 else {
            throw Abort(.serviceUnavailable, reason: "Admin review requires ADMIN_CSRF_SECRET with at least 32 characters configured before state-changing actions can be used.")
        }
        return secret
    }

    private func signature(for payload: String, secret: String) -> String {
        let key = SymmetricKey(data: Data(secret.utf8))
        let code = HMAC<SHA256>.authenticationCode(for: Data(payload.utf8), using: key)
        return Data(code).base64EncodedString()
    }

    private func constantTimeEquals(_ left: String, _ right: String) -> Bool {
        let leftBytes = Array(left.utf8)
        let rightBytes = Array(right.utf8)
        var difference = leftBytes.count ^ rightBytes.count
        for index in 0 ..< max(leftBytes.count, rightBytes.count) {
            let leftByte = index < leftBytes.count ? leftBytes[index] : 0
            let rightByte = index < rightBytes.count ? rightBytes[index] : 0
            difference |= Int(leftByte ^ rightByte)
        }
        return difference == 0
    }
}
