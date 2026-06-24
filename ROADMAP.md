# Galewilliams Site Roadmap

## Direction

Build `galewilliams.com` as a small professional Vapor site that can grow into a client-facing service portal without losing the simplicity of the first public version.

Chosen foundation:

- Vapor for the Swift web app and future JSON API.
- Leaf for server-rendered public pages.
- Fluent with PostgreSQL for persistence.
- Docker first for deploy portability across low-cost hosts.
- Fly.io first for running Swift containers.
- Cloudflare DNS, TLS, caching, R2 downloads, and possibly Cloudflare Containers when the container workflow is proven.
- Stripe Checkout and webhooks for paid productized services once the offer is ready.

## Reusable Swift Web App Standard

Use this site to establish a small repeatable deployment and runtime shape for Gale's future Vapor and Hummingbird apps.

Default production shape:

- Build every app as a Docker container so the same artifact can run on Fly.io, Cloudflare Containers, Railway, Render, Koyeb, AWS, or a small VPS.
- Use Fly.io as the first deploy target for normal Vapor and Hummingbird services because it runs standard containers and has official Vapor deployment guidance.
- Put Cloudflare in front for DNS, TLS, cache rules, redirects, security rules, and static/download asset delivery through R2 where appropriate.
- Keep PostgreSQL as the default relational database and use Fluent where it fits so Vapor and Hummingbird apps can share model and migration patterns.
- Expose a lightweight `/api/health` endpoint in every service.
- Configure services entirely through environment variables and host-managed secrets; do not require machine-local config files for production.
- Keep the app stateless between requests unless a concrete feature introduces durable storage through PostgreSQL, R2, Redis, or another explicit backend.

Provider ranking for Swift web apps:

1. Fly.io for the default Swift container host.
2. Cloudflare Containers as an experiment track after a proof of concept validates the Worker-to-container model, cost, cold starts, and operational complexity.
3. Railway, Render, or Koyeb when a particular project benefits from their simpler managed app/database flow.
4. AWS only when a client, product, or integration already benefits from AWS services enough to justify the extra operational surface.

Standard Cloudflare pieces:

- DNS and TLS for all public domains.
- R2 for `.dmg` downloads, release artifacts, and other large static assets.
- Cache and redirect rules for public pages and marketing assets.
- Turnstile, WAF rules, or bot protections later if intake forms or license APIs attract abuse.
- Cloudflare Containers only after it proves cheaper and smoother than Fly.io for at least one real Swift service.

## Configuration Strategy

Use the active web framework's native configuration path first. For this Vapor app, that means Vapor's `Environment` API and Fluent configuration in `configure.swift`.

Current position:

- Start by keeping the existing environment variable names for Vapor and database config.
- Keep Vapor apps on `Environment.detect()`, `app.environment`, `Environment.get(...)`, and dotenv support unless a real limitation appears.
- Add a small application-owned settings type only after configuration grows beyond database and server settings.
- Keep secrets in Fly.io secrets, Cloudflare secrets, or the selected host's secret store rather than committed config files.
- Use `.env` as a local development template only; do not commit sensitive `.env.*` files.
- For Hummingbird apps, use Hummingbird's `ConfigurationSupport` trait when it is compatible with the package graph.
- Consider `apple/swift-configuration` for Hummingbird apps, framework-neutral libraries, or shared packages where a framework-owned config API would leak the wrong dependency.
- Do not add `swift-configuration` to this Vapor app unless Vapor's native environment API becomes a concrete source of duplication, weak typing, or unclear error handling.

Configuration references:

- [Vapor Environment](https://docs.vapor.codes/basics/environment/)
- [Vapor Fluent configuration](https://docs.vapor.codes/fluent/overview/#configuration)
- [`apple/swift-configuration`](https://github.com/apple/swift-configuration)
- [`swift-configuration` documentation](https://swiftpackageindex.com/apple/swift-configuration/documentation/configuration)
- [SwiftPM package traits](https://docs.swift.org/swiftpm/documentation/packagemanagerdocs/addingdependencies#Packages-with-Traits)
- [Hummingbird package manifest](https://github.com/hummingbird-project/hummingbird/blob/main/Package.swift)
- [HummingbirdFluent](https://github.com/hummingbird-project/hummingbird-fluent)

## Vapor 5 Strategy

Vapor 5 has an alpha release, but the current production site should not depend on it until the ecosystem pieces this app needs are confirmed.

Current position:

- Keep the production-intended branch on stable Vapor 4 until Vapor 5 has the required packages and deployment path.
- Create a separate experiment branch for Vapor 5 alpha once the public pages and intake flow are stable enough to compare.
- Track whether Leaf, Fluent, Fluent Postgres, Stripe integration, queues, JWT, and any auth/passkey packages have Vapor 5-compatible releases.
- Use the Vapor 5 experiment to evaluate:
  - type-safe routing
  - controller macros
  - structured-concurrency cleanup
  - Docker image size and startup behavior
  - memory use on the smallest viable host
- Do not migrate the production roadmap to Vapor 5 until the experiment can build, run, render Leaf pages or an equivalent template strategy, connect to Postgres, and pass the same smoke tests as the Vapor 4 app.

References:

- [Vapor 5 Alpha 1 release](https://github.com/vapor/vapor/releases/tag/5.0.0-alpha.1)
- [Vapor Docker deployment docs](https://docs.vapor.codes/deploy/docker/)
- [Vapor Fly.io deployment docs](https://docs.vapor.codes/deploy/fly/)

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

## Commercial Offer Architecture

Goal: make Gale's services easy to understand, easy to start, and easy to buy without collecting unnecessary detail before the customer has momentum.

### Storefront Tracks

- Consumer-facing pages:
  - local AI agent setup
  - personal automation workflow
  - ChatGPT, Codex, Claude, Xcode, or Zed plugin setup
  - small personal AI app or helper tool
  - consultation-first custom idea
- SMB-facing pages:
  - business automation workflow
  - internal AI agent or assistant
  - team plugin or developer workflow integration
  - flat-rate website or web app
  - flat-rate mobile app
  - web app plus cross-platform mobile app bundle
  - consultation-first custom project
- Apps page:
  - downloadable apps
  - installable plugins
  - license-key-backed products
  - updates, support, and release notes

### Offer Types

- `buy_now_fixed`: bounded, batteries-included products with a clear deliverable, a clear base price, and a short post-purchase intake.
- `buy_now_reviewed`: paid packages that reserve work but still require Gale's review before final scope is accepted.
- `consultation`: free scheduling path for customers who are unsure, have sensitive constraints, or need a deeper conversation.
- `lead_only`: no payment upfront; capture enough detail for Gale to qualify and reply.
- `download`: app or plugin purchase that can fulfill automatically after payment.
- `license_key`: app or plugin purchase that issues a signed license or entitlement after payment.

### Initial Offer Catalog

- Local AI Agent Setup: consumer and SMB variants; review-first unless the supported tools and deliverables are tightly defined.
- AI App Or Assistant Prototype: small scoped app/agent with required concept, target platform, and integration notes.
- Automation Workflow: personal or business workflow; collect apps involved, current manual process, desired output, and privacy constraints.
- Plugin Or Integration: ChatGPT, Codex, Claude, Xcode, Zed, or related developer-tool integration; collect target host, desired commands/actions, inputs, outputs, and install/distribution needs.
- Flat-Rate Website Or Web App: review-first package with a minimum brief, target pages/workflows, data needs, auth needs, and design references.
- Flat-Rate Mobile App: review-first package for iOS, Android, or cross-platform delivery; collect target platforms, core screens, login/account needs, offline needs, push notification needs, and store/distribution expectations.
- Web App Plus Mobile Bundle: review-first package that should require consultation or agent-assisted intake before checkout is considered final.
- Free Consultation: available from Contact, Services, Apps, consumer pages, SMB pages, and post-checkout next-step pages.

### Minimum Intake Fields

Keep the first step short:

- name
- email
- customer type: personal, solo business, SMB, nonprofit, other
- offer or topic
- one-paragraph concept
- target platform or tool, if known
- timeline
- budget comfort or selected package
- privacy or compliance concern, if any
- preference: buy now, schedule a consultation, or ask the site agent for help

Collect deeper detail only after one of these happens:

- the customer chooses a package
- the customer schedules a consultation
- the site agent needs missing information to qualify the lead
- Gale manually requests more detail

### Consultation Scheduling

- Add a persistent "Schedule free consultation" action to Contact, Services, Apps, consumer offer pages, SMB offer pages, checkout success pages, and agent chat outcomes.
- First version can link to a manually configured Google Calendar appointment schedule.
- Prefer Google Meet for the default meeting location because Google Calendar appointment schedules can create Meet appointments directly.
- Fantastical can stay in Gale's personal calendar workflow; the public site should use a stable booking URL or later integrate with Google Calendar APIs rather than depend on a Mac-only local app.
- Store the selected consultation path with the lead or order so Gale can connect scheduling context back to the customer's original concept.

### Lead Notifications

- Add a near-term notification path when a contact form submission or qualified lead arrives.
- First practical version can send a concise email to Gale with the lead summary, selected offer/topic, timeline, and a private follow-up link.
- Keep a personal push-notification app as a soon-after experiment: a tiny iOS/macOS app that registers a device token, lets the Vapor server send APNS notifications for new leads, and becomes the seed for a future lightweight operator console.
- Do not send sensitive project details in push notification bodies; use push to alert and link Gale back to the authenticated admin surface or email details.
- Track delivery attempts and failures so missed notifications do not silently drop important leads.

### Lead And Checkout Agent

- Add a site agent after the public pages and durable intake model exist.
- First job: help visitors turn a rough idea into the minimum useful intake fields.
- Second job: help paid customers complete missing post-checkout details.
- Third job: offer the free consultation path when the customer is unsure, the idea is too custom, or the risk is high.
- Keep the agent advisory, not authoritative. It should qualify, summarize, ask follow-up questions, and route to Gale rather than accept final scope changes alone.
- Store agent conversations as lead/order context with clear consent and retention copy.
- Make the same agent workflow available through the future JSON API so an iOS app can host the same guided intake experience later.

### Tax And Compliance Notes

- Gale's current Stripe account is an individual US account. Treat tax handling as a launch checklist item, not a code-only decision.
- Use Stripe Tax for Checkout when live paid sales begin, unless a tax professional or Stripe setting review says a narrower approach is acceptable.
- Assign product tax codes before selling downloadable software, services, consulting, or mixed bundles because each category can have different tax treatment.
- Keep test mode or invite-only payment links until Stripe Tax settings, business address, payment method domains, terms, refund policy, and support contact are ready.

Commercial offer references:

- [Google Calendar appointment schedules](https://support.google.com/calendar/answer/10729749)
- [Stripe Tax](https://docs.stripe.com/tax)
- [Collect tax with Checkout](https://docs.stripe.com/tax/checkout)
- [Stripe products and prices](https://docs.stripe.com/products-prices/how-products-and-prices-work)
- [Checkout Session create API](https://docs.stripe.com/api/checkout/sessions/create)

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
- Use dynamic payment methods through Stripe's Dashboard-driven payment method settings instead of hard-coding `payment_method_types` unless a specific checkout flow requires an exclusion.
- Use Apple Pay through Stripe Checkout first. Do not build direct Apple Pay JS or merchant-validation plumbing unless Checkout cannot support a real requirement.
- Use Stripe webhooks as the source of truth for fulfillment, not browser redirects.
- Store checkout sessions, payment events, customer identifiers, product identifiers, fulfillment state, and idempotency keys in PostgreSQL.
- Keep purchase completion separate from delivery:
  - payment received
  - entitlement created
  - license or download access issued
  - customer notified
  - support path available

First implementation slice:

- Add product/package records with stable internal slugs and Stripe price lookup keys.
- Add a server endpoint that creates a Checkout Session from a selected offer and redirects to Stripe-hosted Checkout.
- Store a local checkout session record before redirecting.
- Include local order or intake identifiers in Stripe metadata and `client_reference_id` for reconciliation.
- Add a webhook endpoint that verifies the Stripe signature before decoding or persisting the event.
- Handle `checkout.session.completed` first, then expand to `checkout.session.expired`, `payment_intent.succeeded`, `payment_intent.payment_failed`, refund/dispute events, and subscription events only when those products exist.
- Make every Stripe-driven write idempotent using Stripe event IDs, local idempotency keys, and fulfillment state transitions.
- Record detailed operator-facing logs for rejected signatures, unknown product mappings, duplicate events, missing metadata, and failed fulfillment steps.

Required production secrets and settings:

- `STRIPE_SECRET_KEY`
- `STRIPE_WEBHOOK_SECRET`
- `STRIPE_PRICE_*` or database-backed Stripe price lookup keys
- public success and cancel URLs for Checkout redirects
- registered payment method domains in Stripe for every production and test domain that should show Apple Pay

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

Current package choices for the commerce/download/licensing stack:

- [`vapor-community/stripe-kit`](https://swiftpackageindex.com/vapor-community/stripe-kit): preferred Swift server package for Stripe API work. Use it for Checkout Session creation, Customer Portal sessions, webhook event parsing, Stripe object models, idempotency headers, and webhook signature verification when its current API covers the needed fields.
- Lightweight direct Stripe HTTP calls through Vapor's HTTP client: approved fallback for a narrow endpoint or parameter when StripeKit lags Stripe's current API. Keep fallback code isolated behind the same local commerce service so the rest of the app does not care whether a call used StripeKit or a direct request.
- [`vapor-community/stripe`](https://swiftpackageregistry.com/vapor-community/stripe): do not use for new work unless a fresh review finds a current, concrete benefit. Its README presents an older Vapor helper around StripeKit and still demonstrates direct Charges-style usage, which is not the desired integration model.
- [Stripe Checkout](https://docs.stripe.com/payments/checkout): first payment UI for services, apps, plugins, agent packages, and license purchases.
- [Stripe dynamic payment methods](https://docs.stripe.com/payments/payment-methods/dynamic-payment-methods): default payment-method strategy so the Dashboard can manage cards, Link, wallets, and regional methods without code changes.
- [Stripe Apple Pay docs](https://docs.stripe.com/apple-pay?platform=web): preferred Apple Pay path is Stripe Checkout. No extra Apple Pay code is required for Checkout, but every domain and subdomain that displays Apple Pay must be registered in Stripe's payment method domains.
- [Stripe payment method domain registration](https://docs.stripe.com/payments/payment-methods/pmd-registration): required setup for Apple Pay on production and test domains.
- [Apple Pay on the Web server setup](https://developer.apple.com/documentation/applepayontheweb/setting-up-your-server): direct Apple Pay JS support is a later option only if Stripe Checkout or Elements cannot support a real requirement; it adds merchant ID, certificate, domain verification, merchant validation, and HTTPS requirements.
- [`vapor/queues`](https://swiftpackageindex.com/vapor/queues): use a queue driver before sending email, issuing licenses, generating release metadata, or doing webhook fulfillment work that should not block a request.
- [`vapor/jwt`](https://swiftpackageindex.com/vapor/jwt): likely useful for mobile API tokens, admin/client sessions, signed short-lived download claims, or service-to-service auth.
- [`swift-server/webauthn-swift`](https://www.swift.org/documentation/server/guides/passkeys.html): candidate for passkeys when client accounts are real. The Swift.org guide includes a Vapor example and calls out relying-party domain/origin constraints.
- [Swift Crypto](https://www.swift.org/blog/crypto/): preferred signing/verification foundation for offline-validatable license keys before considering smaller third-party Ed25519 packages.
- [AWS SDK for Swift S3](https://docs.aws.amazon.com/sdk-for-swift/latest/developer-guide/using-services-s3.html) plus [Cloudflare R2 presigned URLs](https://developers.cloudflare.com/r2/api/s3/presigned-urls/): likely download-delivery path for paid `.dmg` files. Generate short-lived download URLs after entitlement checks instead of proxying large files through Vapor.
- [`vapor-community/wallet`](https://swiftpackageindex.com/vapor-community/wallet/0.7.1/documentation/vaporwallet): Apple Wallet/pass package, not Apple Pay. Keep in mind only if future products need wallet passes, coupons, tickets, or order passes.

Open questions:

- Does StripeKit expose every current Checkout Session field needed for this app's first offer shape, including metadata, `client_reference_id`, dynamic payment methods, automatic tax, invoice creation, custom fields, and branding settings?
- Can Cloudflare R2 presigned URLs satisfy the desired branded download UX, given R2 presigned URLs use the S3 API hostname rather than custom domains?
- Should license keys be signed JSON payloads, compact binary payloads, or JWT-like tokens? Decide after defining the first paid downloadable product.
- Does any Codex marketplace surface expose a stable install deeplink or CLI install command? Keep this separate from Stripe/download work until verified.
- Does the first purchasable product need sales tax/VAT handling through Stripe Tax before launch, or can the first payment flow stay invite-only/test-mode until the tax posture is clear?
- Which payment events should trigger human review instead of automatic fulfillment for custom service work?

## Phase 2: Durable Intake

- Add a Fluent model and migration for contact/project intake.
- Store submitted intake records in PostgreSQL.
- Add validation that returns clear, human-readable form errors.
- Add an admin-only route to review incoming leads locally.
- Add email notification only after persistence is working.

## Phase 3: Productized Services And Stripe

- Define concrete service packages from the Commercial Offer Architecture catalog.
- Separate packages into consumer-facing, SMB-facing, apps/downloads, and consultation-first groups.
- Decide which offers are safe for `buy_now_fixed`, which require `buy_now_reviewed`, and which should stay `lead_only` until Gale approves scope.
- Create Stripe products/prices or lookup keys for package offerings.
- Add server-side Checkout Session creation.
- Add Stripe webhook verification and idempotent fulfillment records.
- Keep payment success separate from work approval; paid intake should still be reviewed before work begins.
- Add "Schedule free consultation" links to all offer pages and checkout next-step pages.
- Add the lead/checkout agent only after lead persistence and the first manual intake loop are working.

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

- The Mac mini is no longer the production origin. Remove Cloudflare Tunnel as the primary production plan.
- Keep the app Dockerized so the same Vapor build can move between Cloudflare Containers, Fly.io, Railway, Render, Koyeb, or a small VPS.
- Cheapest likely production shape:
  - Cloudflare DNS, TLS, caching, and R2 for downloadable assets.
  - A tiny container host for the Vapor app.
  - Managed Postgres from the cheapest reliable provider that supports backups and connection limits compatible with Fluent.
- Cloudflare Workers alone is not the right target for a normal Vapor binary. Use Cloudflare Containers only if the app can fit the `lite` instance type and the Worker-to-container deployment model stays simple.
- Cloudflare Containers are attractive because they can scale to zero and bill only while active, but they require the Workers Paid plan and also bill Workers/Durable Objects usage around the container.
- Fly.io is the most straightforward Docker/Vapor deployment candidate because Vapor has deployment guidance for it and it can run the app as a normal container.
- Railway, Render, and Koyeb remain useful fallback candidates when deployment simplicity matters more than absolute minimum cost.
- Avoid committing to Cloudflare D1 for the Vapor app while the data layer is Fluent/PostgreSQL; D1 would be a separate architecture decision, not a host swap.
- Add monitoring, backups, and webhook retry visibility before taking paid work through the site.

Hosting references to keep current:

- [Cloudflare Containers pricing](https://developers.cloudflare.com/containers/pricing/)
- [Cloudflare Containers limits and instance types](https://developers.cloudflare.com/containers/platform-details/limits/)
- [Cloudflare Workers pricing](https://developers.cloudflare.com/workers/platform/pricing/)
- [Fly.io resource pricing](https://fly.io/docs/about/pricing/)
- [Render pricing](https://render.com/pricing)
- [Railway pricing](https://railway.com/pricing)
- [Koyeb pricing](https://www.koyeb.com/pricing)
