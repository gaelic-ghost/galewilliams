import Vapor

enum SitePresentation {
    static let origin = (Environment.get("SITE_ORIGIN") ?? "https://galewilliams.com").trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    static let socialImageURL = "\(origin)/images/galewilliams-social-card.png"

    static func canonicalURL(for path: String) -> String {
        path == "/" ? origin : "\(origin)\(path)"
    }
}

struct SiteChrome: Encodable {
    let title: String
    let description: String
    let canonicalURL: String
    let socialImageURL: String
    let robotsDirective: String
    let navItems: [NavigationItem]

    init(title: String, description: String, path: String, shouldIndex: Bool = true) {
        self.title = title
        self.description = description
        canonicalURL = SitePresentation.canonicalURL(for: path)
        socialImageURL = SitePresentation.socialImageURL
        robotsDirective = shouldIndex ? "index, follow" : "noindex, nofollow"
        navItems = Self.navigationItems(currentPath: path)
    }

    private static func navigationItems(currentPath: String) -> [NavigationItem] {
        [
            .init(label: "Home", path: "/", isCurrent: currentPath == "/"),
            .init(label: "Services", path: "/services", isCurrent: currentPath == "/services" || currentPath.hasPrefix("/services/")),
            .init(label: "Apps", path: "/apps", isCurrent: currentPath == "/apps"),
            .init(label: "About", path: "/about", isCurrent: currentPath == "/about"),
            .init(label: "Contact", path: "/contact", isCurrent: currentPath == "/contact"),
        ]
    }
}

struct NavigationItem: Encodable {
    let label: String
    let path: String
    let isCurrent: Bool
}

struct PageIntro: Encodable {
    let eyebrow: String
    let heading: String
    let summary: String
    let className: String

    init(eyebrow: String, heading: String, summary: String, isCompact: Bool = false) {
        self.eyebrow = eyebrow
        self.heading = heading
        self.summary = summary
        className = isCompact ? "page-intro compact-intro" : "page-intro"
    }
}

struct SiteAction: Encodable {
    let label: String
    let path: String
    let className: String

    init(label: String, path: String, style: Style = .secondary) {
        self.label = label
        self.path = path
        className = "button \(style.rawValue)"
    }

    enum Style: String {
        case primary
        case secondary
    }
}

struct SiteNotice: Encodable {
    let message: String
    let className: String
    let role: String
    let liveMode: String

    static func status(_ message: String) -> SiteNotice {
        .init(message: message, className: "status-message", role: "status", liveMode: "polite")
    }

    static func error(_ message: String) -> SiteNotice {
        .init(message: message, className: "form-error", role: "alert", liveMode: "assertive")
    }
}

struct SitePage: Encodable {
    static let home = SitePage(
        title: "Gale Williams | Agentic apps, plugins, and integrations",
        eyebrow: "Independent software studio",
        heading: "Software that makes work easier.",
        summary: "Apps, automations, and integrations built around the way you actually work.",
        description: "Gale Williams builds apps, automations, and integrations around the way you actually work.",
        path: "/",
        actions: [
            .init(label: "View services", path: "/services", style: .primary),
            .init(label: "Start a project", path: "/contact"),
        ],
        actionRowClass: "action-row"
    )

    static let services = SitePage(
        title: "Services | Gale Williams",
        eyebrow: "Services",
        heading: "Software built around your work.",
        summary: "From a focused automation to a new app, we start with the work you want to make easier.",
        description: "Services from Gale Williams for focused apps, automations, and integrations.",
        path: "/services",
        actions: [.init(label: "Start a project", path: "/contact", style: .primary)]
    )

    static let apps = SitePage(
        title: "Apps | Gale Williams",
        eyebrow: "Apps",
        heading: "Apps and plugins.",
        summary: "This is where released software will live. There are no public downloads or installable plugins available right now.",
        description: "Released Gale Williams apps and plugins will appear here when they are publicly available.",
        path: "/apps",
        shouldIndex: false,
        actions: [.init(label: "View services", path: "/services", style: .primary)]
    )

    static let about = SitePage(
        title: "About | Gale Williams",
        eyebrow: "About",
        heading: "Hi, I’m Gale.",
        summary: "I build apps, automations, and integrations that make complicated work easier to handle.",
        description: "Learn about Gale Williams, an independent builder of apps, automations, and integrations.",
        path: "/about"
    )

    static let contact = SitePage(
        title: "Contact | Gale Williams",
        eyebrow: "Contact",
        heading: "Tell me what you need to make.",
        summary: "Share the outcome, platform, constraints, and timeline. I’ll review the details and follow up.",
        description: "Contact Gale Williams about an app, automation, or integration project.",
        path: "/contact"
    )

    let chrome: SiteChrome
    let intro: PageIntro
    let actions: [SiteAction]
    let actionRowClass: String

    init(
        title: String,
        eyebrow: String,
        heading: String,
        summary: String,
        description: String,
        path: String,
        shouldIndex: Bool = true,
        actions: [SiteAction] = [],
        actionRowClass: String = "action-row compact"
    ) {
        chrome = SiteChrome(title: title, description: description, path: path, shouldIndex: shouldIndex)
        intro = PageIntro(eyebrow: eyebrow, heading: heading, summary: summary)
        self.actions = actions
        self.actionRowClass = actionRowClass
    }
}

struct ServiceTrackPage: Encodable {
    let chrome: SiteChrome
    let intro: PageIntro
    let audience: String
    let offers: [ServiceOffer]
    let nextStepNote: String
    let actions: [SiteAction]
    let actionRowClass = "action-row compact"

    init(page: SitePage, audience: String, offers: [ServiceOffer], nextStepNote: String) {
        chrome = page.chrome
        intro = page.intro
        self.audience = audience
        self.offers = offers
        self.nextStepNote = nextStepNote
        actions = [
            .init(label: "Start intake", path: "/contact", style: .primary),
            .init(label: "Compare service tracks", path: "/services"),
        ]
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
