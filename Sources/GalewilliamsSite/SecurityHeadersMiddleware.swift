import Vapor

struct SecurityHeadersMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        var response = try await next.respond(to: request)
        response.headers.replaceOrAdd(name: "Content-Security-Policy", value: "default-src 'self'; base-uri 'self'; form-action 'self'; frame-ancestors 'none'; img-src 'self'; object-src 'none'; style-src 'self'")
        response.headers.replaceOrAdd(name: "Permissions-Policy", value: "camera=(), geolocation=(), microphone=(), payment=()")
        response.headers.replaceOrAdd(name: "Referrer-Policy", value: "strict-origin-when-cross-origin")
        response.headers.replaceOrAdd(name: "X-Content-Type-Options", value: "nosniff")
        response.headers.replaceOrAdd(name: "X-Frame-Options", value: "DENY")
        response.headers.replaceOrAdd(name: "Cross-Origin-Opener-Policy", value: "same-origin")
        return response
    }
}
