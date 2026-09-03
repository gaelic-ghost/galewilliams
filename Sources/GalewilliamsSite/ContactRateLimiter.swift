import Crypto
import Redis
import Vapor

struct ContactRateLimiter {
    private static let maximumSubmissions = 5
    private static let windowSeconds = 600

    func enforce(for request: Request, email: String, clientAddress: String?) async throws {
        guard request.application.environment != .testing else {
            return
        }

        try await enforce(email: email, clientAddress: clientAddress) { identity in
            let key = RedisKey(identity)
            let attempt = try await request.redis.increment(key).get()

            if attempt == 1 {
                _ = try await request.redis.expire(key, after: .seconds(Int64(Self.windowSeconds)))
            }
            return attempt
        }
    }

    func enforce(email: String, clientAddress: String?, increment: (String) async throws -> Int) async throws {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let identities = [("ip", clientAddress ?? "unknown"), ("email", normalizedEmail)]
        for (kind, value) in identities {
            let digest = SHA256.hash(data: Data(value.utf8)).map { String(format: "%02x", $0) }.joined()
            let attempt = try await increment("contact-rate-limit:\(kind):\(digest)")
            guard attempt <= Self.maximumSubmissions else {
                throw Abort(.tooManyRequests, reason: "Secondary contact inquiries are temporarily limited to protect this form from automated abuse. Please wait a few minutes before trying again.")
            }
        }
    }
}
