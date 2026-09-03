import Foundation
@testable import GalewilliamsSite
import Testing
import Vapor

struct ContactProtectionReviewTests {
    @Test("Changing email cannot reset the source-IP quota")
    func sourceIPQuotaSurvivesEmailRotation() async throws {
        let counter = ContactAttemptCounter()
        let limiter = ContactRateLimiter()
        for index in 0..<5 {
            try await limiter.enforce(email: "person\(index)@example.com", clientAddress: "203.0.113.1") { await counter.increment($0) }
        }
        do {
            try await limiter.enforce(email: "another@example.com", clientAddress: "203.0.113.1") { await counter.increment($0) }
            Issue.record("Changing email bypassed the source-IP quota.")
        } catch let error as Abort {
            #expect(error.status == .tooManyRequests)
        }
        try await limiter.enforce(email: "independent@example.com", clientAddress: "203.0.113.2") { await counter.increment($0) }
    }

    @Test("Changing IP cannot reset the normalized-email quota")
    func emailQuotaSurvivesIPRotation() async throws {
        let counter = ContactAttemptCounter()
        let limiter = ContactRateLimiter()
        for index in 0..<5 {
            try await limiter.enforce(email: "person@example.com", clientAddress: "203.0.113.\(index)") { await counter.increment($0) }
        }
        do {
            try await limiter.enforce(email: " Person@example.com ", clientAddress: "203.0.113.9") { await counter.increment($0) }
            Issue.record("Changing IP or email capitalization bypassed the email quota.")
        } catch let error as Abort {
            #expect(error.status == .tooManyRequests)
        }
    }

    @Test("A counter failure rejects rather than bypasses rate limiting")
    func counterFailurePropagates() async {
        await #expect(throws: CounterFailure.self) {
            try await ContactRateLimiter().enforce(email: "person@example.com", clientAddress: nil) { _ in throw CounterFailure.unavailable }
        }
    }

    @Test("Siteverify operational errors are unavailable, not visitor failures")
    func serviceErrorClassification() throws {
        for code in ["missing-input-secret", "invalid-input-secret", "bad-request", "internal-error"] {
            let response = TurnstileVerificationResponse(success: false, hostname: nil, action: nil, errorCodes: [code])
            do {
                try response.validate(expectedHostname: "galewilliams.com")
                Issue.record("A Siteverify service error was accepted.")
            } catch let ContactFormProtectionError.challengeUnavailable(cause) {
                #expect(cause.contains(code))
            }
        }
    }

    @Test("Visitor errors and action/hostname mismatches remain rejected")
    func visitorErrorClassification() throws {
        let responses = [
            TurnstileVerificationResponse(success: false, hostname: nil, action: nil, errorCodes: ["invalid-input-response"]),
            .init(success: false, hostname: nil, action: nil, errorCodes: ["missing-input-response"]),
            .init(success: false, hostname: nil, action: nil, errorCodes: ["timeout-or-duplicate"]),
            .init(success: true, hostname: "galewilliams.com", action: "other", errorCodes: []),
            .init(success: true, hostname: "other.example.com", action: "contact", errorCodes: []),
        ]
        for response in responses {
            do {
                try response.validate(expectedHostname: "galewilliams.com")
                Issue.record("An invalid Siteverify result was accepted.")
            } catch let ContactFormProtectionError.challengeRejected(codes) {
                #expect(!codes.isEmpty)
            }
        }
        try TurnstileVerificationResponse(success: true, hostname: "galewilliams.com", action: "contact", errorCodes: [])
            .validate(expectedHostname: "galewilliams.com")
    }
}

private actor ContactAttemptCounter {
    private var attempts: [String: Int] = [:]

    func increment(_ key: String) -> Int {
        attempts[key, default: 0] += 1
        return attempts[key, default: 0]
    }
}

private enum CounterFailure: Error {
    case unavailable
}
