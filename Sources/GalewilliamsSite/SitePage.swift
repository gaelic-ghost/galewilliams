import Vapor

struct SitePage: Encodable {
    static let home = SitePage(
        title: "Gale Williams | Agentic apps, plugins, and integrations",
        eyebrow: "Independent software studio",
        heading: "Software that makes work easier.",
        summary: "Apps, automations, and integrations built around the way you actually work.",
        path: "/"
    )

    static let services = SitePage(
        title: "Services | Gale Williams",
        eyebrow: "Services",
        heading: "Practical software for people and small teams.",
        summary: "Choose the path that fits the work, from a focused automation to a larger app build.",
        path: "/services"
    )

    static let apps = SitePage(
        title: "Apps | Gale Williams",
        eyebrow: "Apps",
        heading: "Apps and plugins.",
        summary: "This is where released software will live. There are no public downloads or installable plugins available right now.",
        path: "/apps"
    )

    static let about = SitePage(
        title: "About | Gale Williams",
        eyebrow: "About",
        heading: "An Apple-platform and systems-minded builder.",
        summary: "I work where product taste, local tooling, APIs, Swift, and AI systems meet—building software that stays clear after the first demo.",
        path: "/about"
    )

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

    static func contact(statusMessage: String? = nil) -> SitePage {
        SitePage(
            title: "Contact | Gale Williams",
            eyebrow: "Contact",
            heading: "Tell me what you need to make.",
            summary: "Share the outcome, platform, constraints, and timeline. I’ll review the details and follow up.",
            path: "/contact",
            statusMessage: statusMessage
        )
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
    let nextStepNote: String

    init(page: SitePage, audience: String, offers: [ServiceOffer], nextStepNote: String) {
        title = page.title
        navItems = page.navItems
        self.page = page
        self.audience = audience
        self.offers = offers
        self.nextStepNote = nextStepNote
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

struct HealthResponse: Content {
    let status: String
    let service: String
}
