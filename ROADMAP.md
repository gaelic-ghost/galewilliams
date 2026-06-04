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
- Existing icon/banner assets copied into `Public/images`.

## Apps And Software Distribution Plan

Goal: add an `Apps` page that can grow from a simple software catalog into a download, purchase, licensing, and update surface for Gale's apps, plugins, and agent products.

### Apps Page

- Add a top-level `/apps` page to the public navigation.
- Start with a catalog of software products, each with:
  - product name
  - short value proposition
  - platform or runtime
  - current release status
  - download or install action
  - purchase action when applicable
  - support/contact action
- Keep the first version content-managed in code or static data; move to PostgreSQL only when the catalog needs admin editing, release history, entitlements, or purchase state.

### Codex Plugin Install Links

- Investigate whether Codex GUI supports a public plugin marketplace deeplink for installing or adding a plugin.
- Investigate whether Codex CLI exposes a stable marketplace install command or URL handoff.
- Do not publish guessed install URLs. Expose a manual install command or documentation fallback until an official deeplink or CLI command is verified.
- Track the verified install surface per plugin:
  - GUI deeplink, if available
  - CLI command, if available
  - marketplace listing URL, if available
  - source repository URL
  - manual install instructions
- Official references checked during planning:
  - [Plugins in Codex](https://help.openai.com/en/articles/20001256-plugins-in-codex)
  - [Using Codex with your ChatGPT plan](https://help.openai.com/en/articles/11369540-using-codex-with-your-chatgpt-plan)
  - [OpenAI Codex CLI: Getting Started](https://help.openai.com/en/articles/11096431-openai-codex-cli-getting-started)

### DMG Downloads

- Host `.dmg` downloads as release artifacts rather than ad hoc public files.
- Store per-release metadata:
  - app identifier
  - version
  - build number
  - minimum macOS version
  - download URL
  - file size
  - SHA-256 checksum
  - notarization status
  - release notes
- Prefer object storage or a durable release-artifact backend for production downloads; keep local Mac mini serving as a development or small-scale origin only after backups and monitoring are in place.
- Add an app release detail page before accepting payments for downloadable apps.
- Future update support can add Sparkle appcast metadata when a Mac app needs automatic updates.

### Purchases And Stripe

- Model apps/plugins/services as product records with a fulfillment type:
  - `download`
  - `license-key`
  - `codex-plugin`
  - `agent-service`
  - `custom-project`
- Use Stripe Checkout for first purchase flows.
- Use Stripe webhooks as the source of truth for fulfillment, not browser redirects.
- Store checkout sessions, payment events, customer identifiers, product identifiers, fulfillment state, and idempotency keys in PostgreSQL.
- Keep purchase completion separate from delivery:
  - payment received
  - entitlement created
  - license or download access issued
  - customer notified
  - support path available

### License Keys And Key Server

- Treat licensing as entitlement verification, not heavy DRM.
- Start with signed license keys that can be validated locally by an app without calling home on every launch.
- Add a key server API only when products need revocation, seat limits, activations, upgrades, or customer self-service.
- Initial API surfaces to plan:
  - create entitlement from Stripe webhook
  - issue license key
  - verify license key
  - activate installation
  - deactivate installation
  - rotate/reissue license key
  - revoke entitlement
- Store only the minimum useful device or activation metadata. Avoid collecting sensitive local machine data unless a product has a concrete licensing need and a clear privacy disclosure.
- Keep admin override tools explicit so Gale can manually grant, revoke, or repair licenses when Stripe or fulfillment state is wrong.

### Security And Abuse Notes

- Never serve paid downloads from guessable public paths without an entitlement check or expiring signed URL.
- Rate-limit license verification and activation endpoints.
- Make webhook handling idempotent and auditable.
- Keep all Stripe secrets, signing keys, and license private keys outside the repository.
- Add clear operator logs for every failed fulfillment, license issuance, and webhook verification error.

### Package And Integration Research

Current package candidates to evaluate before implementing the commerce/download/licensing stack:

- [`vapor-community/stripe-kit`](https://swiftpackageindex.com/vapor-community/stripe-kit): strongest Swift server candidate for Stripe API work. Use this for Checkout Session creation, Customer Portal sessions, webhook event parsing, and Stripe object models if it covers the needed current API surface.
- [`vapor-community/stripe`](https://swiftpackageregistry.com/vapor-community/stripe): older Vapor helper around StripeKit. Treat as a secondary candidate only if it still adds useful Vapor-specific request/application integration after reviewing the current API.
- [Stripe Checkout](https://docs.stripe.com/payments/checkout) and [Stripe Express Checkout Element](https://docs.stripe.com/elements/express-checkout-element): preferred Apple Pay path for first commerce flows. Apple Pay support should come through Stripe-hosted Checkout or Express Checkout before attempting a direct Apple Pay JS integration.
- [Stripe Apple Pay docs](https://docs.stripe.com/apple-pay?platform=web): verify domain registration, dashboard payment-method activation, browser/device support, and currency/account constraints before promising Apple Pay visibility on every client.
- [Apple Pay on the Web server setup](https://developer.apple.com/documentation/applepayontheweb/setting-up-your-server): direct Apple Pay JS support is a later option if Stripe-hosted flows are not enough; it adds merchant ID, certificate, domain verification, merchant validation, and HTTPS requirements.
- [`vapor/queues`](https://swiftpackageindex.com/vapor/queues): use a queue driver before sending email, issuing licenses, generating release metadata, or doing webhook fulfillment work that should not block a request.
- [`vapor/jwt`](https://swiftpackageindex.com/vapor/jwt): likely useful for mobile API tokens, admin/client sessions, signed short-lived download claims, or service-to-service auth.
- [`swift-server/webauthn-swift`](https://www.swift.org/documentation/server/guides/passkeys.html): candidate for passkeys when client accounts are real. The Swift.org guide includes a Vapor example and calls out relying-party domain/origin constraints.
- [Swift Crypto](https://www.swift.org/blog/crypto/): preferred signing/verification foundation for offline-validatable license keys before considering smaller third-party Ed25519 packages.
- [AWS SDK for Swift S3](https://docs.aws.amazon.com/sdk-for-swift/latest/developer-guide/using-services-s3.html) plus [Cloudflare R2 presigned URLs](https://developers.cloudflare.com/r2/api/s3/presigned-urls/): likely download-delivery path for paid `.dmg` files. Generate short-lived download URLs after entitlement checks instead of proxying large files through Vapor.
- [`vapor-community/wallet`](https://swiftpackageindex.com/vapor-community/wallet/0.7.1/documentation/vaporwallet): Apple Wallet/pass package, not Apple Pay. Keep in mind only if future products need wallet passes, coupons, tickets, or order passes.

Open questions:

- Does `stripe-kit` expose the current Checkout, Customer Portal, webhook signature, and Apple Pay-relevant fields we need, or should the app use lightweight direct HTTP calls for the first Stripe slice?
- Can Cloudflare R2 presigned URLs satisfy the desired branded download UX, given R2 presigned URLs use the S3 API hostname rather than custom domains?
- Should license keys be signed JSON payloads, compact binary payloads, or JWT-like tokens? Decide after defining the first paid downloadable product.
- Does any Codex marketplace surface expose a stable install deeplink or CLI install command? Keep this separate from Stripe/download work until verified.

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
