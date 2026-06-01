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
- The intake workflow should store submissions first, then add agent-assisted completeness checks behind explicit review gates.
- Client accounts, Sign in with Apple, passkeys, and a client portal should wait until there is a real account-backed workflow to expose.
- Blog support should be a later content model and route group, not mixed into the initial public-page slice.
