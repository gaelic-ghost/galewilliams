import Vapor

struct SitemapController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get("sitemap", use: sitemapPage)
        routes.get("sitemap.xml", use: xmlSitemap)
        routes.get("robots.txt", use: robots)
    }

    func sitemapPage(request: Request) async throws -> Response {
        try await request.view.render("sitemap", SitemapPage()).encodeResponse(for: request)
    }

    func xmlSitemap(request: Request) -> Response {
        let urls = PublicSiteMap.entries.map { "    <url><loc>\(xmlEscaped(SitePresentation.canonicalURL(for: $0.path)))</loc></url>" }
        let body = ([
            "<?xml version=\"1.0\" encoding=\"UTF-8\"?>",
            "<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">",
        ] + urls + ["</urlset>"]).joined(separator: "\n")
        return plainResponse(body, contentType: "application/xml; charset=utf-8")
    }

    func robots(request: Request) -> Response {
        let sitemapURL = SitePresentation.canonicalURL(for: "/sitemap.xml")
        return plainResponse("User-agent: *\nAllow: /\nSitemap: \(sitemapURL)\n", contentType: "text/plain; charset=utf-8")
    }

    private func plainResponse(_ body: String, contentType: String) -> Response {
        var headers = HTTPHeaders()
        headers.replaceOrAdd(name: .contentType, value: contentType)
        return Response(status: .ok, headers: headers, body: .init(string: body))
    }

    private func xmlEscaped(_ value: String) -> String {
        value
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }
}

enum PublicSiteMap {
    static let entries: [SitemapEntry] = [
        .init(label: "Home", summary: "Independent software studio for apps, automations, and integrations.", path: "/"),
        .init(label: "Services", summary: "Browse personal and small-business service tracks.", path: "/services"),
        .init(label: "Personal services", summary: "Personal AI tools, automations, and integrations.", path: "/services/personal"),
        .init(label: "Business services", summary: "Business automation, app, and integration services.", path: "/services/business"),
        .init(label: "About", summary: "Learn about Gale Williams.", path: "/about"),
        .init(label: "Contact", summary: "Start a project intake.", path: "/contact"),
    ]
}

struct SitemapEntry: Encodable {
    let label: String
    let summary: String
    let path: String
}

struct SitemapPage: Encodable {
    let chrome = SiteChrome(
        title: "Sitemap | Gale Williams",
        description: "Browse the public pages on the Gale Williams site.",
        path: "/sitemap"
    )
    let intro = PageIntro(
        eyebrow: "Sitemap",
        heading: "Find the part you need.",
        summary: "A simple index of the public Gale Williams site."
    )
    let entries = PublicSiteMap.entries
}
