# Galewilliams Site Roadmap

## Direction

Build `galewilliams.com` as a small professional Vapor site that can grow into a client-facing service portal without losing the simplicity of the first public version.

Chosen foundation:

- Vapor for the Swift web app and future JSON API.
- Leaf for server-rendered public pages.
- Fluent with PostgreSQL for persistence.
- Docker or Docker Compose first for Mac mini hosting.
- Cloudflare Tunnel for public ingress to the Mac mini.
- Stripe Checkout and webhooks for paid productized services once the offer is ready.

## Phase 1: Public Presence

- Homepage with clear positioning.
- Services page with productized service categories.
- About page with a practical builder profile.
- Contact page with an intake form.
- Shared Leaf layout, navigation, footer, and CSS.
- Visual alignment with the purple/neon icon and banner style in `~/Documents/icons`.

Current status:

- SwiftPM package initialized.
- Vapor, Leaf, Fluent, and Postgres dependencies declared.
- Public routes and `/api/health` scaffolded.
- Existing icon/banner assets copied into package resources.

## Phase 2: Durable Intake

- Add a Fluent model and migration for contact/project intake.
- Store submitted intake records in PostgreSQL.
- Add validation that returns clear, human-readable form errors.
- Add an admin-only route to review incoming leads locally.
- Add email notification only after persistence is working.

## Phase 3: Productized Services And Stripe

- Define concrete service packages such as:
  - Agent prototype.
  - Plugin or integration.
  - Small app build.
  - Automation workflow.
- Create Stripe products/prices or lookup keys for package offerings.
- Add server-side Checkout Session creation.
- Add Stripe webhook verification and idempotent fulfillment records.
- Keep payment success separate from work approval; paid intake should still be reviewed before work begins.

## Phase 4: Auth And Client Portal

- Add owner/admin auth first.
- Add client accounts only when clients have useful account-backed state to view.
- Plan support for Sign in with Apple and passkeys.
- Add client views for orders, project status, invoices, and follow-up requests.
- Keep browser session auth and mobile API auth intentionally separated.

## Phase 5: Blog And Content

- Add a blog/content model after the public site and intake workflow are stable.
- Keep posts as durable records or portable Markdown, with one clear source of truth.
- Support RSS if the blog becomes public-facing and recurring.

## Hosting Notes

- Start production hosting with Docker or Docker Compose on the Mac mini.
- Keep Apple container tooling as an experiment until restart, logging, volumes, service supervision, and deployment behavior are proven.
- Put Cloudflare Tunnel in front of the app, with Cloudflare DNS and TLS.
- Add monitoring, backups, and webhook retry visibility before taking paid work through the site.
