import Testing
import Vapor
import VaporTesting
@testable import GalewilliamsSite

@Suite("GalewilliamsSite Tests")
struct GalewilliamsSiteTests {
    private func withApp(_ test: (Application) async throws -> Void) async throws {
        let app = try await Application.make(.testing)
        do {
            try configure(app)
            try await test(app)
            try await app.asyncShutdown()
        } catch {
            try? await app.asyncShutdown()
            throw error
        }
    }

    @Test("Primary pages expose expected paths")
    func primaryPagesExposeExpectedPaths() async throws {
        #expect(SitePage.home.path == "/")
        #expect(SitePage.services.path == "/services")
        #expect(SitePage.apps.path == "/apps")
        #expect(SitePage.about.path == "/about")
        #expect(SitePage.contact().path == "/contact")
    }

    @Test("Primary navigation includes Apps")
    func primaryNavigationIncludesApps() async throws {
        let labels = SitePage.home.navItems.map(\.label)

        #expect(labels == ["Home", "Services", "Apps", "About", "Contact"])
    }

    @Test("Contact page can carry a status message")
    func contactPageCanCarryStatusMessage() async throws {
        let page = SitePage.contact(statusMessage: "Captured.")

        #expect(page.statusMessage == "Captured.")
        #expect(page.title.contains("Contact"))
    }

    @Test("Public routes render successfully")
    func publicRoutesRenderSuccessfully() async throws {
        try await withApp { app in
            for path in ["/", "/services", "/services/personal", "/services/business", "/apps", "/about", "/contact"] {
                try await app.testing().test(.GET, path) { response async in
                    #expect(response.status == .ok)
                    #expect(response.body.string.contains("Gale Williams"))
                }
            }
        }
    }
}
