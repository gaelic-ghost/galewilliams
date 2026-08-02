import Vapor

func routes(_ app: Application) throws {
    app.get { request async throws in
        try await request.view.render("home", SitePage.home).encodeResponse(for: request)
    }

    app.get("favicon.ico") { request in
        request.redirect(to: "/images/sharp-icon.png", redirectType: .permanent)
    }

    app.get("services") { request async throws in
        try await request.view.render("services", SitePage.services).encodeResponse(for: request)
    }

    app.get("services", "personal") { request async throws in
        try await request.view.render("service-track", OfferCatalog.personalServices).encodeResponse(for: request)
    }

    app.get("services", "business") { request async throws in
        try await request.view.render("service-track", OfferCatalog.businessServices).encodeResponse(for: request)
    }

    app.get("apps") { request async throws in
        try await request.view.render("apps", SitePage.apps).encodeResponse(for: request)
    }

    app.get("about") { request async throws in
        try await request.view.render("about", SitePage.about).encodeResponse(for: request)
    }

    try app.register(collection: ContactController())
    try app.register(collection: AdminController())

    try app.register(collection: HealthController())
    try app.register(collection: SitemapController())
}
