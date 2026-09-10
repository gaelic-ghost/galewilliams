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
        title: "Gale Williams | iOS and macOS software engineer",
        eyebrow: "Independent software engineer",
        heading: "Software for iPhone, iPad, and Mac.",
        summary: "I design and build native Apple-platform products end to end, from screens and features to the system services and backends they depend on.",
        description: "Gale Williams designs and builds native iPhone, iPad, and Mac apps, system software, and supporting Swift services.",
        path: "/",
        actions: [
            .init(label: "View services", path: "/services", style: .primary),
            .init(label: "Start a project", path: "/contact"),
        ],
        actionRowClass: "action-row"
    )

    static let services = SitePage(
        title: "iOS and macOS Software Services | Gale Williams",
        eyebrow: "Services",
        heading: "Apple-platform software, built end to end.",
        summary: "I build native iPhone, iPad, and Mac apps, system tools, and the Swift services behind them.",
        description: "End-to-end iOS and macOS software development, including native apps, Mac system software, Swift backends, integrations, and audio products.",
        path: "/services",
        actions: [.init(label: "Start a project", path: "/contact", style: .primary)]
    )

    static let apps = SitePage(
        title: "Apps and Releases | Gale Williams",
        eyebrow: "Apps",
        heading: "Apps and releases",
        summary: "Released apps, TestFlight betas, downloads, and support links will appear here as they become available.",
        description: "Apps, TestFlight betas, downloads, and support information from Gale Williams.",
        path: "/apps",
        shouldIndex: false,
        actions: [.init(label: "View services", path: "/services", style: .primary)]
    )

    static let about = SitePage(
        title: "About | Gale Williams",
        eyebrow: "About",
        heading: "Hi, I’m Gale.",
        summary: "I’m an independent software engineer focused on native apps and system software for Apple platforms.",
        description: "Learn about Gale Williams, an independent iOS and macOS software engineer focused on end-to-end Apple-platform products.",
        path: "/about"
    )

    static let contact = SitePage(
        title: "Contact | Gale Williams",
        eyebrow: "Contact",
        heading: "Let’s find the right place to talk.",
        summary: "Start a software project through Upwork, or use the secondary form for another kind of inquiry.",
        description: "Contact Gale Williams about software projects and other professional inquiries.",
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

struct HealthResponse: Content {
    let status: String
    let service: String
}
