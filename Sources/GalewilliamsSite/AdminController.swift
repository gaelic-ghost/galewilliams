import Fluent
import Vapor

struct AdminController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let admin = routes.grouped("admin").grouped(AdminAuthMiddleware())

        admin.get { request async throws in
            request.redirect(to: "/admin/leads")
        }
        admin.get("leads", use: listLeads)
        admin.get("leads", ":leadID", use: showLead)
        admin.post("leads", ":leadID", "review", use: reviewLead)
    }

    func listLeads(request: Request) async throws -> Response {
        let leads = try await LeadSubmission.query(on: request.db)
            .filter(\.$status == "new")
            .sort(\.$createdAt, .descending)
            .all()

        let page = AdminLeadListPage(leads: leads.map(AdminLeadSummary.init(lead:)))
        return try await request.view.render("admin-leads", page).encodeResponse(for: request)
    }

    func showLead(request: Request) async throws -> Response {
        let lead = try await request.requireLeadSubmission()
        let page = AdminLeadDetailPage(lead: AdminLeadDetail(lead: lead))

        return try await request.view.render("admin-lead-detail", page).encodeResponse(for: request)
    }

    func reviewLead(request: Request) async throws -> Response {
        let lead = try await request.requireLeadSubmission()
        lead.status = "reviewed"
        lead.reviewedAt = Date()
        try await lead.save(on: request.db)

        guard let id = lead.id else {
            throw Abort(.internalServerError, reason: "Lead was reviewed but no identifier was available for redirect.")
        }

        return request.redirect(to: "/admin/leads/\(id.uuidString)")
    }
}

struct AdminLeadListPage: Encodable {
    let title = "Lead Review | Gale Williams"
    let navItems = SitePage.home.navItems
    let leads: [AdminLeadSummary]
    let hasLeads: Bool
    let emptyMessage = "No new leads are waiting for review."

    init(leads: [AdminLeadSummary]) {
        self.leads = leads
        hasLeads = leads.isEmpty == false
    }
}

struct AdminLeadSummary: Encodable {
    let id: UUID
    let name: String
    let email: String
    let projectType: String
    let timeline: String
    let status: String
    let createdAt: Date?

    init(lead: LeadSubmission) {
        id = lead.id ?? UUID()
        name = lead.name
        email = lead.email
        projectType = lead.projectType
        timeline = lead.timeline
        status = lead.status
        createdAt = lead.createdAt
    }
}

struct AdminLeadDetailPage: Encodable {
    let title = "Lead Detail | Gale Williams"
    let navItems = SitePage.home.navItems
    let lead: AdminLeadDetail
}

struct AdminLeadDetail: Encodable {
    let id: UUID
    let name: String
    let email: String
    let projectType: String
    let timeline: String
    let details: String
    let status: String
    let createdAt: Date?
    let reviewedAt: Date?
    let canMarkReviewed: Bool

    init(lead: LeadSubmission) {
        id = lead.id ?? UUID()
        name = lead.name
        email = lead.email
        projectType = lead.projectType
        timeline = lead.timeline
        details = lead.details
        status = lead.status
        createdAt = lead.createdAt
        reviewedAt = lead.reviewedAt
        canMarkReviewed = lead.status != "reviewed"
    }
}

private extension Request {
    func requireLeadSubmission() async throws -> LeadSubmission {
        guard let id = parameters.get("leadID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Admin lead route is missing a readable lead identifier.")
        }
        guard let lead = try await LeadSubmission.find(id, on: db) else {
            throw Abort(.notFound, reason: "No lead submission exists for the requested identifier.")
        }

        return lead
    }
}
