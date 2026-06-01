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
        heading: "Focused builds for agents, apps, plugins, and integrations.",
        summary: "Pick a concrete outcome: prototype an agent, automate a workflow, integrate an API, build a small app, or turn a fuzzy tool idea into something customers can actually use.",
        path: "/services"
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

struct ContactIntake: Content {
    let name: String
    let email: String
    let projectType: String
    let timeline: String
    let details: String
}

struct HealthResponse: Content {
    let status: String
    let service: String
}
