import Crypto
import Redis
import Vapor

struct ContactRateLimiter {
    private static let maximumSubmissions = 5
    private static let windowSeconds = 600

    func enforce(for request: Request) async throws {
        guard request.application.environment != .testing else {
            return
        }

        let address = request.remoteAddress?.ipAddress ?? "unknown"
        let digest = SHA256.hash(data: Data(address.utf8)).map { String(format: "%02x", $0) }.joined()
        let key = RedisKey("contact-rate-limit:\(digest)")
        let attempt = try await request.redis.increment(key).get()

        if attempt == 1 {
            _ = try await request.redis.expire(key, after: .seconds(Int64(Self.windowSeconds)))
        }

        guard attempt <= Self.maximumSubmissions else {
            throw Abort(.tooManyRequests, reason: "Contact intake is temporarily limited to protect this form from automated abuse. Please wait a few minutes before trying again.")
        }
    }
}
