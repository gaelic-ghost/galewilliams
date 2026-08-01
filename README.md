# Galewilliams Site

A Vapor and Leaf site for `galewilliams.com`.

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Usage](#usage)
- [Development](#development)
- [Repo Structure](#repo-structure)
- [Release Notes](#release-notes)
- [License](#license)

## Overview

### Status

TBD

### What This Project Is

A server-rendered professional site built with Vapor, Leaf, Fluent, PostgreSQL,
Redis, and Docker. It serves public pages, accepts project intake, keeps lead
review behind owner authentication, and records notification delivery work
durably before Redis and Amazon SES process it.

### Motivation

TBD

## Quick Start

The public site is available at [galewilliams.com](https://galewilliams.com).
It is a web service rather than a locally installed end-user application; use
the development commands below when working on the service itself.

## Usage

Public pages include the homepage, services, apps, about, and contact routes.
The contact form persists a complete intake before notification delivery is
queued, so temporary Redis or SES configuration problems do not discard a
lead. Owner administration uses the credentials supplied through environment
variables; it is not a public account system.

Operational readiness is split deliberately:

- `/api/health` reports whether the Vapor web process is running.
- `/api/ready` additionally verifies PostgreSQL access before the service is
  treated as ready to accept durable intake.

## Development

Copy `.env.example` to an uncommitted `.env` file and replace its local-only
placeholders before running Compose-backed flows. Build and test the package:

```sh
swift build
swift test
```

Start local dependencies and run the integration path:

```sh
docker compose up -d db redis
scripts/test-integration.sh
```

Run the development server or the complete local Compose service set:

```sh
swift run GalewilliamsSite serve --hostname 127.0.0.1 --port 8080
docker compose up app worker scheduler
```

Run migrations against the local Compose database with:

```sh
swift run GalewilliamsSite migrate
```

Use `scripts/repo-maintenance/validate-all.sh` for the repository maintainer
validation gate. The production environment, deployment sequence, recovery
checks, and host-managed secrets are documented in
[AWS_DEPLOYMENT.md](AWS_DEPLOYMENT.md).

## Repo Structure

```text
.
├── Sources/GalewilliamsSite/       Vapor routes, controllers, models, workers
├── Tests/GalewilliamsSiteTests/    Swift Testing coverage
├── Resources/Views/                Leaf layouts and page templates
├── Public/                         Runtime-served styles and images
├── scripts/repo-maintenance/       Validation, sync, and release entrypoints
├── docker-compose.yml              Local Compose services
├── docker-compose.production.yml   Production Compose services
└── AWS_DEPLOYMENT.md               Lightsail, Cloudflare, SES, and recovery runbook
```

## Release Notes

Versioned Git tags are the release record. The production workflow builds the
tagged container image, runs the forward-only migration step before activation,
and checks both health and readiness endpoints. See
[AWS_DEPLOYMENT.md](AWS_DEPLOYMENT.md) for the operational runbook and the
[GitHub Releases page](https://github.com/gaelic-ghost/galewilliams/releases)
for published release notes.

## License

This repository is proprietary. See [NOTICE](NOTICE); all rights are reserved
for its code and content.
