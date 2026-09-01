import Vapor

struct SecurityHeadersMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let response = try await next.respond(to: request)
        let turnstileSources = request.url.path == "/contact"
            ? "; script-src 'self' https://challenges.cloudflare.com; frame-src https://challenges.cloudflare.com"
            : ""
        response.headers.replaceOrAdd(name: "Content-Security-Policy", value: "default-src 'self'; base-uri 'self'; form-action 'self'; frame-ancestors 'none'; img-src 'self'; object-src 'none'; style-src 'self'\(turnstileSources)")
        response.headers.replaceOrAdd(name: "Permissions-Policy", value: "camera=(), geolocation=(), microphone=(), payment=()")
        response.headers.replaceOrAdd(name: "Referrer-Policy", value: "strict-origin-when-cross-origin")
        response.headers.replaceOrAdd(name: "X-Content-Type-Options", value: "nosniff")
        response.headers.replaceOrAdd(name: "X-Frame-Options", value: "DENY")
        response.headers.replaceOrAdd(name: "Cross-Origin-Opener-Policy", value: "same-origin")
        return response
    }
}
