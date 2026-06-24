enum OfferCatalog {
    static let personalServices = ServiceTrackPage(
        page: SitePage(
            title: "Personal AI Tools | Gale Williams",
            eyebrow: "Personal services",
            heading: "Practical AI tools for your own workflow.",
            summary: "Small, bounded builds for people who want a local assistant, a useful automation, or a plugin that makes the tools they already use feel sharper.",
            path: "/services/personal"
        ),
        audience: "Personal, creator, and solo-operator work",
        offers: [
            ServiceOffer(
                kicker: "Local agent",
                title: "Local AI Agent Setup",
                summary: "A focused assistant that helps with one repeatable personal workflow while keeping your approval in the loop.",
                details: [
                    "Good for file triage, writing workflows, research capture, or local automation.",
                    "Starts with the concept, tools involved, and what a useful result looks like.",
                    "Review-first until the supported toolchain and deliverable are tightly defined.",
                ],
                actionLabel: "Start agent intake",
                actionPath: "/contact"
            ),
            ServiceOffer(
                kicker: "Automation",
                title: "Personal Automation Workflow",
                summary: "Turn a repeated manual routine into a small script, app shortcut, dashboard, or agent-assisted checklist.",
                details: [
                    "Good for recurring admin, content prep, reports, local files, and cross-app glue.",
                    "Requires the current manual process, desired output, and privacy constraints.",
                    "Can become a buy-now package once the workflow type is repeatable.",
                ],
                actionLabel: "Describe the workflow",
                actionPath: "/contact"
            ),
            ServiceOffer(
                kicker: "Plugin",
                title: "ChatGPT, Codex, Claude, Xcode, Or Zed Plugin",
                summary: "A compact plugin or integration that adds one sharp capability to a tool you already rely on.",
                details: [
                    "Good for command surfaces, local project helpers, API bridges, and review flows.",
                    "Requires host app, desired actions, inputs, outputs, and install expectations.",
                    "Distribution can start manual, then graduate to the Apps page.",
                ],
                actionLabel: "Plan a plugin",
                actionPath: "/contact"
            ),
        ],
        consultationNote: "If the idea is fuzzy, start with a free consultation instead of forcing the form to know everything."
    )

    static let businessServices = ServiceTrackPage(
        page: SitePage(
            title: "SMB AI And App Builds | Gale Williams",
            eyebrow: "SMB services",
            heading: "Flat-rate starting points for business software.",
            summary: "Clear entry points for teams that need an internal agent, a workflow integration, a web app, a mobile app, or a combined product build.",
            path: "/services/business"
        ),
        audience: "Small-business and team workflows",
        offers: [
            ServiceOffer(
                kicker: "Operations",
                title: "Business Automation Workflow",
                summary: "A reviewed workflow build for the manual process your team keeps repeating.",
                details: [
                    "Good for intake, reporting, handoffs, data cleanup, and operator review queues.",
                    "Requires apps involved, current process, success criteria, and sensitive-data notes.",
                    "Payment should reserve the work; final scope still gets reviewed.",
                ],
                actionLabel: "Start business intake",
                actionPath: "/contact"
            ),
            ServiceOffer(
                kicker: "Web",
                title: "Flat-Rate Website Or Web App",
                summary: "A scoped site or web app package with a practical first release, not a forever-discovery swamp.",
                details: [
                    "Good for professional sites, portals, dashboards, forms, and small SaaS-style tools.",
                    "Requires pages or workflows, data needs, auth needs, and design references.",
                    "Stripe checkout comes after the offer boundaries are explicit.",
                ],
                actionLabel: "Scope a web build",
                actionPath: "/contact"
            ),
            ServiceOffer(
                kicker: "Mobile",
                title: "Flat-Rate Mobile App Or Web Plus Mobile Bundle",
                summary: "A review-first package for iOS, Android, cross-platform apps, or a web app with mobile companion.",
                details: [
                    "Good for MVPs, internal tools, customer apps, and guided intake experiences.",
                    "Requires target platforms, core screens, login needs, offline needs, and distribution plan.",
                    "Bundle work should include a consultation or agent-assisted intake before checkout is final.",
                ],
                actionLabel: "Scope an app build",
                actionPath: "/contact"
            ),
        ],
        consultationNote: "For business-critical or sensitive work, the best first step is a short consultation and a reviewed scope."
    )

    static let appListings = [
        AppListing(
            status: "Planned",
            title: "Codex And ChatGPT Plugins",
            summary: "Installable agent and workflow plugins with clear setup paths, support notes, and eventually purchase or license actions.",
            platform: "Codex, ChatGPT, Claude, Xcode, Zed",
            actionLabel: "Ask about plugins",
            actionPath: "/contact"
        ),
        AppListing(
            status: "Planned",
            title: "Mac And Local AI Utilities",
            summary: "Downloadable tools for local agents, automation, review flows, and personal productivity.",
            platform: "macOS first",
            actionLabel: "Follow app releases",
            actionPath: "/contact"
        ),
        AppListing(
            status: "Future",
            title: "Guided Intake App",
            summary: "A mobile version of the site agent that helps customers shape an idea, complete missing details, and schedule a call.",
            platform: "iOS and web API",
            actionLabel: "Discuss the app",
            actionPath: "/contact"
        ),
    ]
}
