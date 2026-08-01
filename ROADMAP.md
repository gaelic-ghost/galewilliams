# Galewilliams Site Roadmap

This roadmap tracks the site as a small professional Vapor service that can
grow deliberately without pulling commercial, account, or portal scope ahead
of the operational foundation.

## Table of Contents

- [Vision](#vision)
- [Product Principles](#product-principles)
- [Milestone Progress](#milestone-progress)
- [Milestone 1: Public Presence and Durable Intake](#milestone-1-public-presence-and-durable-intake)
- [Milestone 2: Operational Foundation and Discovery](#milestone-2-operational-foundation-and-discovery)
- [Milestone 3: Productized Services and Stripe](#milestone-3-productized-services-and-stripe)
- [Milestone 4: Auth and Client Portal](#milestone-4-auth-and-client-portal)
- [Milestone 5: Blog and Content](#milestone-5-blog-and-content)
- [Small Tickets](#small-tickets)
- [Backlog Candidates](#backlog-candidates)
- [History](#history)

## Vision

Provide a clear professional presence and a durable, reviewable route for
people to start work with Gale. The service should remain a compact
server-rendered Vapor site until a proven customer workflow earns a broader
product, account, or client-application surface.

## Product Principles

- Keep public HTML and future `/api/...` behavior separate so a mobile client
  can reuse backend behavior without inheriting browser-page contracts.
- Prefer Vapor's native environment configuration and host-managed secrets;
  add another configuration layer only for a concrete problem.
- Store intake before attempting notification, payment, or other asynchronous
  work, and keep human review authoritative for custom scope and fulfillment.
- Complete migration safety, intake hardening, readiness/recovery, and public
  metadata before starting checkout, booking, a portal, or a commercial catalog.
- Keep the production service on stable Vapor 4 while Vapor 5 remains an alpha
  experiment with an explicit compatibility and deployment test plan.

## Milestone Progress

- Milestone 1: Public Presence and Durable Intake - Completed
- Milestone 2: Operational Foundation and Discovery - In Progress
- Milestone 3: Productized Services and Stripe - Planned
- Milestone 4: Auth and Client Portal - Planned
- Milestone 5: Blog and Content - Planned

## Milestone 1: Public Presence and Durable Intake

### Status

Completed

### Scope

- [x] Deliver the first server-rendered public site, durable contact intake,
  owner lead review, and post-persistence notification workflow.

### Tickets

- [x] Build homepage, services, apps, about, contact, shared Leaf layout,
  navigation, footer, and the purple/neon public presentation.
- [x] Keep Vapor and Fluent public service behavior distinct from future JSON
  API behavior; expose `/api/health`.
- [x] Persist contact and project intake in PostgreSQL with clear validation.
- [x] Provide owner-authenticated lead listing, inspection, and reviewed state.
- [x] Queue Amazon SES notifications through Redis only after the lead and its
  delivery record are durable, with retries and reconciliation support.
- [x] Prove the end-to-end intake path with the Compose-backed integration test.

### Exit Criteria

- [x] Public pages render from Leaf and the contact form can persist a lead.
- [x] A notification outage leaves a reviewable lead and a descriptive delivery
  state rather than dropping intake.

## Milestone 2: Operational Foundation and Discovery

### Status

In Progress

### Scope

- [ ] Make releases migration-safe and recoverable, harden the public intake
  surface, establish readiness/recovery/monitoring, and complete public
  discovery metadata before commercial work begins.

### Tickets

- [x] Use tag-triggered production deployment with an expand/contract
  compatibility check before a candidate migration, runtime rollback only when
  that forward-compatible migration permits it, and a tested database restore
  path before destructive schema removal. Check health and readiness after
  activation.
- [x] Render canonical URLs, robots directives, a root sitemap, and a dedicated
  Gale Williams social-preview card from encoded Leaf page contexts.
- [x] Add rate limiting and a hidden anti-automation field to contact intake.
- [ ] Select, implement, and verify a PostgreSQL backup-and-restore procedure;
  a Lightsail snapshot alone is not a tested database recovery plan.
- [ ] Select and verify uptime/readiness monitoring with a clear operator
  response path.
- [ ] Add the canonical `www` redirect only after the record and every intended
  hostname are verified over HTTPS; defer HSTS until then.
- [ ] Add immutable-asset cache behavior without caching public HTML, contact,
  admin, or API responses.
- [ ] Complete the SES custom MAIL FROM and DMARC-enforcement progression only
  with provider-supplied records and observed reports.

### Exit Criteria

- [ ] A tested restore procedure, monitoring evidence, and the public metadata
  contract exist alongside the migration-safe tagged release path.
- [ ] The site can be recovered and assessed without treating a green container
  build as proof of a ready intake service.

## Milestone 3: Productized Services and Stripe

### Status

Planned

### Scope

- [ ] Define approved, bounded offers and a review-safe checkout/fulfillment
  path without making the site agent or payment redirect authoritative.

### Tickets

- [ ] Define concrete consumer, SMB, app/download, and consultation-first
  packages; classify each as fixed purchase, reviewed purchase, lead-only,
  consultation, download, or license-key fulfillment.
- [ ] Keep the first intake short: name, email, customer type, offer/topic,
  concept, platform/tool, timeline, budget comfort, privacy concern, and
  preferred next step. Collect deeper details only after a justified trigger.
- [ ] Add a public Fantastical booking link only after Gale supplies its stable
  public URL; do not substitute a Google Calendar or local-Mac dependency.
- [ ] Start payments with Stripe Checkout and webhooks. Persist checkout state
  before redirecting, verify webhook signatures, and make fulfillment writes
  idempotent by Stripe event and local state.
- [ ] Keep payment completion separate from custom-work approval. Require Gale's
  review for scope changes, pricing exceptions, refunds, legal/tax claims, and
  fulfillment commitments.
- [ ] Decide Stripe Tax posture, payment method domains, terms, refund policy,
  support contact, and product tax codes before any live paid launch.
- [ ] Model downloads as entitlement-gated release artifacts with short-lived
  access URLs, checksums, notarization status, and release notes.
- [ ] Begin licensing with signed locally verifiable entitlements; add a key
  server only when revocation, activations, seats, upgrades, or self-service
  create a concrete need.
- [ ] Add a site agent only as an advisory intake/completeness assistant behind
  clear consent, retention, and human-review gates.

### Exit Criteria

- [ ] At least one approved offer has an end-to-end, review-safe test-mode flow
  with durable intake, payment verification, and operator-visible recovery.

## Milestone 4: Auth and Client Portal

### Status

Planned

### Scope

- [ ] Add account-backed behavior only when a real client workflow exists.

### Tickets

- [ ] Keep owner administration separate from future client authentication.
- [ ] Define useful client state before adding accounts: orders, project status,
  invoices, follow-up requests, or entitlements.
- [ ] Plan Sign in with Apple and passkeys after the account boundary is real.
- [ ] Keep browser sessions and mobile API credentials intentionally separate.

### Exit Criteria

- [ ] Clients can access a deliberately defined, useful account-backed workflow
  without exposing owner operations or mixing browser and mobile auth contracts.

## Milestone 5: Blog and Content

### Status

Planned

### Scope

- [ ] Add durable public content after the public site and intake workflow are
  stable.

### Tickets

- [ ] Choose one source of truth for posts: durable records or portable
  Markdown.
- [ ] Add a distinct blog model and route group rather than mixing posts into
  the initial public-page slice.
- [ ] Add RSS if the blog becomes a recurring public publishing surface.

### Exit Criteria

- [ ] Posts have one durable source of truth, public routes, and an intentional
  publishing/recovery workflow.

## Small Tickets

No issue-sized tickets were found in the current source TODO/FIXME scan or open
GitHub issue audit on 2026-08-01.

## Backlog Candidates

- [ ] Run a separate, pinned Vapor 5 alpha experiment only after stable Vapor 4
  public pages and intake can serve as a comparison baseline. Inventory Leaf,
  Fluent, Postgres, queues, auth, and deployment compatibility first.
- [ ] Evaluate Cloudflare Containers, Fly.io, Railway, Render, Koyeb, and other
  hosts for future Swift services only through a concrete cost, cold-start,
  operational-complexity, and deployment proof; do not treat a host swap as a
  Fluent/PostgreSQL architecture decision.
- [ ] Investigate a verified Codex plugin install surface before publishing a
  deeplink; retain a manual, documented installation path until then.

## History

- 2026-08-01: Converted the legacy phase-and-prose roadmap into the canonical
  milestone checklist schema; retained the operational-first commercial gate
  and reconciled public booking with the project contract.
