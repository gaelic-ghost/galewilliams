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
- Use `bootstrap-swift-package` when a new Swift package repo still needs to be created from scratch.
- Use `sync-swift-package-guidance` when the repo guidance for this package drifts and needs to be refreshed or merged forward.
- Re-run `sync-swift-package-guidance` after substantial package-workflow or plugin updates so local guidance stays aligned.
- Use `swift-package-build-run-workflow` for manifest, dependency, plugin, resource, Metal-distribution, build, and run work when `Package.swift` is the source of truth.
- Use `swift-package-testing-workflow` for Swift Testing, XCTest holdouts, `.xctestplan`, fixtures, and package test diagnosis.
- Keep `Package.swift` explicit about Swift 6 language mode with `swiftLanguageModes: [.v6]`.
- Prefer `swift package` subcommands for structural package edits before manually editing `Package.swift`.
- Edit `Package.swift` intentionally and keep it readable; agents may modify it when package structure, targets, products, or dependencies need to change, and should try to keep package graph updates consolidated in one change when possible.
- Keep `swift-configuration` as the default configuration dependency for Swift packages unless the package has a concrete reason to remove it. The preferred manifest shape depends on `https://github.com/apple/swift-configuration` from `1.2.0`, enables the `.defaults`, `Reloading`, `YAML`, and `CommandLineArguments` package traits, and adds the `Configuration` product to the primary target. Add the `PropertyList` trait when the package should parse property-list configuration, and add the `Logging` trait when configuration access should integrate with `SwiftLog.Logger`.
- Keep dependency provenance concise but explicit enough for another contributor to fetch the same package: use package-manager, package-registry, GitHub URL, or other real remote repository requirements, and do not commit machine-local dependency paths such as `/Users/...`, `~/...`, `../...`, local worktrees, or private checkout paths. Avoid branch- or revision-based requirements unless the user explicitly asks for that level of control.
- Prefer Swift Testing for tests.
- Validate package changes with:
  - `swift build`
  - `swift test`
- Use `scripts/repo-maintenance/validate-all.sh` for local maintainer validation and `scripts/repo-maintenance/sync-shared.sh` for repo-local sync steps.
- Use `scripts/repo-maintenance/release.sh --mode standard --version vX.Y.Z` from a feature branch or worktree only when the task is actually a protected-main release, publish, merge, tag, or release-PR preparation.
- Do not run the standard release workflow from `main`; when a protected-main release is explicitly requested, let it validate, bump versions, tag, push the branch and tag, open the release PR, watch CI, address valid PR comments or record out-of-scope concerns in `ROADMAP.md`, merge to protected `main`, fast-forward local `main`, and clean up stale branches.
- Treat `scripts/repo-maintenance/config/profile.env` as the installed `maintain-project-repo` profile marker, and keep it on the `swift-package` profile for plain package repos.
- Prefer a checked-in repo-root `.swiftformat` file as the Swift formatting source of truth.
- Prefer a pre-commit hook such as `scripts/repo-maintenance/hooks/pre-commit.sample` that formats staged Swift sources and then verifies them with `swiftformat --lint` before commit.
- Treat SwiftLint as an optional complementary signal layer for clarity, safety, and maintainability after SwiftFormat owns formatting shape.
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
