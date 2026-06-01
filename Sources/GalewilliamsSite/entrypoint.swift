import Vapor

@main
enum GalewilliamsSite {
    static func main() async throws {
        var environment = try Environment.detect()
        try LoggingSystem.bootstrap(from: &environment)

        let app = try await Application.make(environment)
        do {
            try configure(app)
            try await app.execute()
            try await app.asyncShutdown()
        } catch {
            try? await app.asyncShutdown()
            throw error
        }
    }
}
