enum OfferCatalog {
    static let personalServices = ServiceTrackPage(
        page: SitePage(
            title: "Personal AI Tools | Gale Williams",
            eyebrow: "Personal services",
            heading: "Practical AI tools for your own workflow.",
            summary: "Small, bounded builds for people who want a local assistant, a useful automation, or a plugin that makes the tools they already use feel sharper.",
            description: "Personal apps, local AI helpers, automations, and tool integrations from Gale Williams.",
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
                    "Ends with a clear handoff for the workflow we define together.",
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
                    "Includes a clear install and handoff path for the supported host app.",
                ],
                actionLabel: "Plan a plugin",
                actionPath: "/contact"
            ),
        ],
        nextStepNote: "If the idea is still taking shape, send the useful parts first. We can clarify the rest together."
    )

    static let businessServices = ServiceTrackPage(
        page: SitePage(
            title: "SMB AI And App Builds | Gale Williams",
            eyebrow: "SMB services",
            heading: "Flat-rate starting points for business software.",
            summary: "Clear entry points for teams that need an internal agent, a workflow integration, a web app, a mobile app, or a combined product build.",
            description: "Business automation, app, and integration services from Gale Williams.",
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
                    "Ends with a reviewed scope and a practical handoff plan.",
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
                    "Starts with the pages or workflows that matter most.",
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
                    "Starts by agreeing on the core experience across each platform.",
                ],
                actionLabel: "Scope an app build",
                actionPath: "/contact"
            ),
        ],
        nextStepNote: "For business-critical or sensitive work, start with the outcome, constraints, and people involved."
    )
}
