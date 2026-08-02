# Contributing to galewilliams

Use this guide when preparing changes so the project stays understandable, runnable, and reviewable for the next contributor.

## Table of Contents

- [Overview](#overview)
- [Contribution Workflow](#contribution-workflow)
- [Local Setup](#local-setup)
- [Development Expectations](#development-expectations)
- [Pull Request Expectations](#pull-request-expectations)
- [Communication](#communication)
- [License and Contribution Terms](#license-and-contribution-terms)

## Overview

### Who This Guide Is For

Use this guide for source, template, stylesheet, test, and documentation
changes to the Galewilliams Site. It is for approved contributors working on
the Vapor service, not a deployment runbook for the live site.

### Before You Start

Read [README.md](README.md), this guide, and the nearest source or template
before changing it. Check the current branch and worktree first; create a
`scope/slug` feature branch before editing `main`. Keep production credentials
and host operations in [AWS_DEPLOYMENT.md](AWS_DEPLOYMENT.md), not in local
dotenv files or commits.

## Contribution Workflow

### Choosing Work

Confirm the requested outcome and the affected public routes, intake flow, or
operational surface before editing. Keep public HTML routes separate from
future `/api/...` routes, and raise a decision when work would introduce a new
architectural layer or materially widen scope.

### Making Changes

Make coherent, focused changes in Swift, Leaf templates, public assets, and
tests together when they describe one behavior. Preserve the server-rendered
Vapor and Leaf shape unless a separate frontend is explicitly approved. Keep
runtime secrets in ignored dotenv files and use environment variables rather
than hard-coding configuration.

### Asking For Review

Review the diff for unintended template, generated, or configuration changes.
Before requesting review, run the checks relevant to the changed surface and
state what passed, what was not run, and any follow-up decision a reviewer
needs to make.

## Local Setup

### Runtime Config

Copy `.env.example` to the ignored `.env.development` file and set local-only
values. Do not commit either dotenv file.

The native daily-development path uses Homebrew PostgreSQL and Redis:

```zsh
brew services start postgresql@18
brew services start redis

createuser --login --pwprompt galewilliams
createdb --owner=galewilliams galewilliams_site
```

Set `DATABASE_HOST=127.0.0.1`, `DATABASE_PORT=5432`,
`DATABASE_USERNAME=galewilliams`, `DATABASE_PASSWORD` to the password chosen
above, `DATABASE_NAME=galewilliams_site`, and
`REDIS_URL=redis://127.0.0.1:6379`. Set
`SITE_ORIGIN=http://127.0.0.1:8080` so local canonical and social URLs do not
claim the production site. Use a distinct local admin password and a
32-character-or-longer `ADMIN_CSRF_SECRET` when exercising admin routes.

Leave AWS and SES variables empty unless intentionally testing email delivery.
Docker Compose remains the parity and integration path; it owns its own
PostgreSQL and Redis containers.

### Runtime Behavior

Confirm the native services before starting Vapor:

```zsh
pg_isready -h 127.0.0.1 -p 5432
redis-cli ping
swift run GalewilliamsSite migrate --yes
swift run GalewilliamsSite serve --hostname 127.0.0.1 --port 8080
```

Open `http://127.0.0.1:8080/`; both `/api/health` and `/api/ready` should
return JSON with an `ok` or `ready` status. Start a notifications worker only
when testing queued notification delivery, and the scheduler only when testing
reconciliation:

```zsh
swift run GalewilliamsSite queues --queue notifications
swift run GalewilliamsSite queues --scheduled
```

The app does not provide automatic Swift hot reload; restart the server after
Swift or Leaf changes. Static asset changes can be checked with a browser
refresh.

## Development Expectations

### Naming Conventions

Use Swift’s standard UpperCamelCase for types and lowerCamelCase for members.
Name Leaf templates, CSS classes, routes, and page-model properties after their
user-visible purpose. Keep reusable presentation pieces in dedicated Leaf
components rather than duplicating markup across pages.

### Accessibility Expectations

Treat accessibility as normal change quality. For UI work, preserve semantic
landmarks, the skip link, visible focus, keyboard navigation, form labels and
errors, sufficient contrast, and meaningful assistive-technology announcements.
Extend the rendered-page assertions when a change affects those contracts; this
repository does not currently maintain a separate `ACCESSIBILITY.md`.

### Verification

Run validation serially, selecting the narrowest useful checks first:

```zsh
swift build
swift test
scripts/test-integration.sh
scripts/repo-maintenance/validate-all.sh
```

`scripts/test-integration.sh` uses Compose-backed PostgreSQL and Redis; run it
when changing durable intake, Redis queues, migrations, or admin review.

## Pull Request Expectations

Use a focused branch and commit sequence. A review request should state the
user-visible outcome, key implementation choices, validation performed, and
any migration, deployment, or production follow-up. Do not include secrets,
ignored dotenv files, or unrelated formatting churn.

## Communication

Raise uncertainty before adding dependencies, storage, queues, external
services, or a new architectural boundary. Describe the concrete problem, the
smallest viable extension, and the impact on local and production runtime
behavior so maintainers can make the scope decision deliberately.

## License and Contribution Terms

This is proprietary work. [NOTICE](NOTICE) reserves all rights; contributing,
copying, publishing, or distributing material requires prior written
permission from the copyright holder.
