import Vapor

struct SitePage: Encodable {
    let title: String
    let eyebrow: String
    let heading: String
    let summary: String
    let path: String
    let statusMessage: String?
    let navItems: [NavigationItem] = [
        .init(label: "Home", path: "/"),
        .init(label: "Services", path: "/services"),
        .init(label: "Apps", path: "/apps"),
        .init(label: "About", path: "/about"),
        .init(label: "Contact", path: "/contact"),
    ]

    static let home = SitePage(
        title: "Gale Williams | Agentic apps, plugins, and integrations",
        eyebrow: "Independent software studio",
        heading: "Agentic software for people who need the work to move.",
        summary: "I build practical apps, integrations, plugins, and agent workflows with a bias toward clear systems, humane tools, and shipping the first useful version.",
        path: "/"
    )

    static let services = SitePage(
        title: "Services | Gale Williams",
        eyebrow: "Services",
        heading: "Clear ways to start, from tiny automations to full app builds.",
        summary: "Pick the lane that matches your problem. Personal tools stay lightweight and direct. Business builds get the intake, review, and delivery structure they need.",
        path: "/services"
    )

    static let apps = SitePage(
        title: "Apps | Gale Williams",
        eyebrow: "Apps",
        heading: "Apps, plugins, and agents ready to install or buy.",
        summary: "This will become the distribution shelf for downloadable apps, Codex and ChatGPT plugins, license-backed tools, and release notes. For now, it marks the product surface we are building toward.",
        path: "/apps"
    )

    static let about = SitePage(
        title: "About | Gale Williams",
        eyebrow: "About",
        heading: "A senior Apple-platform and systems-minded builder.",
        summary: "I work best where product taste, local tooling, APIs, Swift, and AI systems meet. The goal is durable software that feels clear to operate after the first exciting demo.",
        path: "/about"
    )

    static func contact(statusMessage: String? = nil) -> SitePage {
        SitePage(
            title: "Contact | Gale Williams",
            eyebrow: "Contact",
            heading: "Bring a real problem and enough detail to start.",
            summary: "Use the intake form to describe the outcome, platform, constraints, and timeline. The next slice will turn this into a reviewed lead workflow backed by Postgres.",
            path: "/contact",
            statusMessage: statusMessage
        )
    }

    init(
        title: String,
        eyebrow: String,
        heading: String,
        summary: String,
        path: String,
        statusMessage: String? = nil
    ) {
        self.title = title
        self.eyebrow = eyebrow
        self.heading = heading
        self.summary = summary
        self.path = path
        self.statusMessage = statusMessage
    }
}

struct NavigationItem: Encodable {
    let label: String
    let path: String
}

struct ServiceTrackPage: Encodable {
    let title: String
    let navItems: [NavigationItem]
    let page: SitePage
    let audience: String
    let offers: [ServiceOffer]
    let consultationNote: String

    init(page: SitePage, audience: String, offers: [ServiceOffer], consultationNote: String) {
        self.title = page.title
        self.navItems = page.navItems
        self.page = page
        self.audience = audience
        self.offers = offers
        self.consultationNote = consultationNote
    }
}

struct ServiceOffer: Encodable {
    let kicker: String
    let title: String
    let summary: String
    let details: [String]
    let actionLabel: String
    let actionPath: String
}

struct AppListing: Encodable {
    let status: String
    let title: String
    let summary: String
    let platform: String
    let actionLabel: String
    let actionPath: String
}

struct HealthResponse: Content {
    let status: String
    let service: String
}
