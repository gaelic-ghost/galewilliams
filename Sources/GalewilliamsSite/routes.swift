import Vapor

func routes(_ app: Application) throws {
    app.get { request async throws in
        try await request.view.render("home", SitePage.home).encodeResponse(for: request)
    }

    app.get("favicon.ico") { request in
        request.redirect(to: "/images/sharp-icon.png", redirectType: .permanent)
    }

    app.get("services") { request async throws in
        try await request.view.render("services", ServicesLanding(page: .services)).encodeResponse(for: request)
    }

    app.get("services", "personal") { request async throws in
        try await request.view.render("service-track", OfferCatalog.personalServices).encodeResponse(for: request)
    }

    app.get("services", "business") { request async throws in
        try await request.view.render("service-track", OfferCatalog.businessServices).encodeResponse(for: request)
    }

    app.get("apps") { request async throws in
        try await request.view.render("apps", AppsPage(page: .apps, listings: OfferCatalog.appListings)).encodeResponse(for: request)
    }

    app.get("about") { request async throws in
        try await request.view.render("about", SitePage.about).encodeResponse(for: request)
    }

    try app.register(collection: ContactController())
    try app.register(collection: AdminController())

    app.group("api") { api in
        api.get("health") { _ in
            HealthResponse(status: "ok", service: "GalewilliamsSite")
        }
    }
}

private struct ServicesLanding: Encodable {
    let title: String
    let navItems: [NavigationItem]
    let page: SitePage

    init(page: SitePage) {
        self.title = page.title
        self.navItems = page.navItems
        self.page = page
    }
}

private struct AppsPage: Encodable {
    let title: String
    let navItems: [NavigationItem]
    let page: SitePage
    let listings: [AppListing]

    init(page: SitePage, listings: [AppListing]) {
        self.title = page.title
        self.navItems = page.navItems
        self.page = page
        self.listings = listings
    }
}
