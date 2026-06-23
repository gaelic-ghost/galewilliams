# AGENTS.md

## Project Shape

- This repository is a Swift Package Manager Vapor application for `galewilliams.com`.
- The first production shape is a server-rendered professional site with Leaf templates, public assets, a future JSON API, and PostgreSQL through Fluent.
- Use Vapor for routing, middleware, static files, request decoding, and response rendering.
- Use Leaf for public HTML pages unless a future client portal earns a dedicated frontend app.
- Use Fluent with `FluentPostgresDriver` for persistent site, intake, account, order, and blog data.
- Keep public HTML routes and `/api/...` routes separate so a mobile app can reuse the backend without inheriting browser page behavior.

## Visual Direction

- Align the site with Gale's existing purple/neon icon and banner assets from `~/Documents/icons`.
- Current reference assets copied into `Public/images`:
  - `sharp-icon.png`
  - `speak-swiftly-banner.png`
  - `socket-banner.png`
- Preserve the core aesthetic: black ground, neon violet glow, scanline texture, hard geometric marks, high contrast, cool accent colors, and sharp segmented surfaces.
- Prefer real generated bitmap or existing brand assets over decorative SVG-only hero art.
- Do not use machine-local asset paths in templates, CSS, docs intended for the repo, or runtime configuration.

## Swift Package Workflow

- Use Swift Package Manager as the source of truth for package structure and dependencies.
- Keep `Package.swift` explicit about Swift 6 language mode with `swiftLanguageModes: [.v6]`.
- Prefer Swift Testing for tests.
- Validate package changes with:
  - `swift build`
  - `swift test`
- Run SwiftPM and other heavy validation commands serially.
- Treat `Package.resolved` as generated; do not hand-edit it.

## Local Runtime

- Use Vapor's `Environment` API as the default runtime configuration path for this app.
- Prefer `Environment.detect()`, `app.environment`, `Environment.get(...)`, dotenv support, and Fluent configuration in `configure.swift` over adding a separate configuration package.
- Add `apple/swift-configuration` only if Vapor's native environment API becomes a concrete source of duplication, weak typing, or unclear error handling.
- The app reads PostgreSQL configuration from:
  - `DATABASE_HOST`
  - `DATABASE_PORT`
  - `DATABASE_USERNAME`
  - `DATABASE_PASSWORD`
  - `DATABASE_NAME`
- Local defaults are development-only and should not be used as production credentials.
- Static assets are served from the Vapor public directory at repo-root `Public`.

## Future Architecture Notes

- Stripe should start with hosted Checkout and webhooks, not direct card collection.
- Prefer `vapor-community/stripe-kit` for Stripe API work; avoid the older `vapor-community/stripe` wrapper unless a fresh review finds a current concrete benefit.
- Apple Pay should come through Stripe Checkout and Stripe payment method domain setup before considering direct Apple Pay JS integration.
- The intake workflow should store submissions first, then add agent-assisted completeness checks behind explicit review gates.
- A site agent may help visitors qualify ideas, complete missing intake details, and schedule consultations, but it must not finalize custom scope, pricing exceptions, refunds, legal/tax claims, or fulfillment commitments without Gale's review.
- Client accounts, Sign in with Apple, passkeys, and a client portal should wait until there is a real account-backed workflow to expose.
- Blog support should be a later content model and route group, not mixed into the initial public-page slice.
