import Foundation
import Vapor

struct AdminAuthMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let credentials = try AdminCredentials.load()
        guard request.adminCredentialsMatch(credentials) else {
            var headers = HTTPHeaders()
            headers.add(name: .wwwAuthenticate, value: #"Basic realm="Gale Williams Admin""#)
            throw Abort(.unauthorized, headers: headers, reason: "Admin routes require owner credentials.")
        }

        return try await next.respond(to: request)
    }
}

private struct AdminCredentials {
    let username: String
    let password: String

    static func load() throws -> AdminCredentials {
        guard let username = Environment.get("ADMIN_USERNAME")?.trimmedForAdminCredential, username.isEmpty == false else {
            throw Abort(.serviceUnavailable, reason: "Admin routes need ADMIN_USERNAME configured before they can be used.")
        }
        guard let password = Environment.get("ADMIN_PASSWORD")?.trimmedForAdminCredential, password.isEmpty == false else {
            throw Abort(.serviceUnavailable, reason: "Admin routes need ADMIN_PASSWORD configured before they can be used.")
        }

        return AdminCredentials(username: username, password: password)
    }
}

private extension Request {
    func adminCredentialsMatch(_ expected: AdminCredentials) -> Bool {
        guard let authorization = headers.first(name: .authorization),
              authorization.hasPrefix("Basic ")
        else {
            return false
        }

        let encoded = String(authorization.dropFirst("Basic ".count))
        guard let data = Data(base64Encoded: encoded) else {
            return false
        }

        return constantTimeEquals(data, Data("\(expected.username):\(expected.password)".utf8))
    }

    private func constantTimeEquals(_ left: Data, _ right: Data) -> Bool {
        let leftBytes = Array(left)
        let rightBytes = Array(right)
        let longestLength = max(leftBytes.count, rightBytes.count)
        var difference = leftBytes.count ^ rightBytes.count

        for index in 0..<longestLength {
            let leftByte = index < leftBytes.count ? leftBytes[index] : 0
            let rightByte = index < rightBytes.count ? rightBytes[index] : 0
            difference |= Int(leftByte ^ rightByte)
        }

        return difference == 0
    }
}

private extension String {
    var trimmedForAdminCredential: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
