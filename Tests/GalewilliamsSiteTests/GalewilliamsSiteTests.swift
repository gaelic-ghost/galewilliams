import Testing
@testable import GalewilliamsSite

@Test func primaryPagesExposeExpectedPaths() async throws {
    #expect(SitePage.home.path == "/")
    #expect(SitePage.services.path == "/services")
    #expect(SitePage.about.path == "/about")
    #expect(SitePage.contact().path == "/contact")
}

@Test func contactPageCanCarryStatusMessage() async throws {
    let page = SitePage.contact(statusMessage: "Captured.")

    #expect(page.statusMessage == "Captured.")
    #expect(page.title.contains("Contact"))
}
