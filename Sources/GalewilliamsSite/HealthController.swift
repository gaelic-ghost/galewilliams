import Fluent
import Vapor

struct HealthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let api = routes.grouped("api")
        api.get("health", use: health)
        api.get("ready", use: ready)
    }

    func health(request: Request) -> HealthResponse {
        HealthResponse(status: "ok", service: "GalewilliamsSite")
    }

    func ready(request: Request) async throws -> HealthResponse {
        _ = try await LeadSubmission.query(on: request.db).limit(1).first()
        return HealthResponse(status: "ready", service: "GalewilliamsSite")
    }
}
