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

    app.get("about") { request async throws in
        try await request.view.render("about", SitePage.about).encodeResponse(for: request)
    }

    app.get("contact") { request async throws in
        try await request.view.render("contact", SitePage.contact()).encodeResponse(for: request)
    }

    app.post("contact") { request async throws in
        let intake = try request.content.decode(ContactIntake.self)
        request.logger.info("Received contact intake for \(intake.email) about \(intake.projectType).")

        let message = "Thanks. Your project details are captured locally for the next intake workflow slice."
        return try await request.view.render("contact", SitePage.contact(statusMessage: message)).encodeResponse(for: request)
    }

    app.group("api") { api in
        api.get("health") { _ in
            HealthResponse(status: "ok", service: "GalewilliamsSite")
        }
    }
}
