import Vapor

enum SitePresentation {
    static let origin = (Environment.get("SITE_ORIGIN") ?? "https://galewilliams.com").trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    static let socialImageURL = "\(origin)/images/galewilliams-social-card.png"

    static func canonicalURL(for path: String) -> String {
        path == "/" ? origin : "\(origin)\(path)"
    }
}

struct SitePage: Encodable {
    static let home = SitePage(
        title: "Gale Williams | Agentic apps, plugins, and integrations",
        eyebrow: "Independent software studio",
        heading: "Software that makes work easier.",
        summary: "Apps, automations, and integrations built around the way you actually work.",
        description: "Gale Williams builds apps, automations, and integrations around the way you actually work.",
        path: "/"
    )

    static let services = SitePage(
        title: "Services | Gale Williams",
        eyebrow: "Services",
        heading: "Software built around your work.",
        summary: "From a focused automation to a new app, we start with the work you want to make easier.",
        description: "Services from Gale Williams for focused apps, automations, and integrations.",
        path: "/services"
    )

    static let apps = SitePage(
        title: "Apps | Gale Williams",
        eyebrow: "Apps",
        heading: "Apps and plugins.",
        summary: "This is where released software will live. There are no public downloads or installable plugins available right now.",
        description: "Released Gale Williams apps and plugins will appear here when they are publicly available.",
        path: "/apps",
        shouldIndex: false
    )

    static let about = SitePage(
        title: "About | Gale Williams",
        eyebrow: "About",
        heading: "Hi, I’m Gale.",
        summary: "I build apps, automations, and integrations that make complicated work easier to handle.",
        description: "Learn about Gale Williams, an independent builder of apps, automations, and integrations.",
        path: "/about"
    )

    let title: String
    let eyebrow: String
    let heading: String
    let summary: String
    let description: String
    let path: String
    let statusMessage: String?
    let shouldIndex: Bool
    let navItems: [NavigationItem] = [
        .init(label: "Home", path: "/"),
        .init(label: "Services", path: "/services"),
        .init(label: "Apps", path: "/apps"),
        .init(label: "About", path: "/about"),
        .init(label: "Contact", path: "/contact"),
    ]

    var canonicalURL: String { SitePresentation.canonicalURL(for: path) }
    var socialImageURL: String { SitePresentation.socialImageURL }
    var robotsDirective: String { shouldIndex ? "index, follow" : "noindex, nofollow" }

    init(
        title: String,
        eyebrow: String,
        heading: String,
        summary: String,
        description: String,
        path: String,
        statusMessage: String? = nil,
        shouldIndex: Bool = true
    ) {
        self.title = title
        self.eyebrow = eyebrow
        self.heading = heading
        self.summary = summary
        self.description = description
        self.path = path
        self.statusMessage = statusMessage
        self.shouldIndex = shouldIndex
    }

    static func contact(statusMessage: String? = nil) -> SitePage {
        SitePage(
            title: "Contact | Gale Williams",
            eyebrow: "Contact",
            heading: "Tell me what you need to make.",
            summary: "Share the outcome, platform, constraints, and timeline. I’ll review the details and follow up.",
            description: "Contact Gale Williams about an app, automation, or integration project.",
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
    let description: String
    let canonicalURL: String
    let socialImageURL: String
    let robotsDirective: String
    let navItems: [NavigationItem]
    let page: SitePage
    let audience: String
    let offers: [ServiceOffer]
    let nextStepNote: String

    init(page: SitePage, audience: String, offers: [ServiceOffer], nextStepNote: String) {
        title = page.title
        description = page.description
        canonicalURL = page.canonicalURL
        socialImageURL = page.socialImageURL
        robotsDirective = page.robotsDirective
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
