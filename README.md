# Galewilliams Site

A Vapor and Leaf site for `galewilliams.com`.

## Local SwiftPM

Build the package:

```sh
swift build
```

Run tests:

```sh
swift test
```

Run the Compose-backed intake integration test:

```sh
scripts/test-integration.sh
```

This starts local PostgreSQL and Redis if needed, then verifies that a contact
submission persists, queues its notification, and completes the authenticated
lead-review flow.

Start the development server:

```sh
swift run GalewilliamsSite serve --hostname 127.0.0.1 --port 8080
```

Run migrations against the local Compose database:

```sh
docker compose up -d db
swift run GalewilliamsSite migrate --yes
```

Owner admin routes are protected with HTTP Basic credentials from:

```sh
ADMIN_USERNAME
ADMIN_PASSWORD
```

## Local Docker

Validate the Compose file:

```sh
docker compose config
```

Build the app image:

```sh
docker compose build
```

Start PostgreSQL, Redis, and the app:

```sh
docker compose up db redis app
```

Run database migrations:

```sh
docker compose run migrate
```

Run the durable lead-notification worker in a second terminal:

```sh
docker compose up worker
```

Run the reconciler in a third terminal. It returns notification records that
were saved while Redis or SES configuration was unavailable to the queue after
the dependency recovers:

```sh
docker compose up scheduler
```

The worker requires `AWS_REGION`, `SES_FROM_EMAIL`, and
`LEAD_NOTIFICATION_TO_EMAIL`. It obtains AWS credentials through the standard
AWS SDK credential chain, so production should use an instance role or
host-managed credentials rather than committed secrets.

The Compose file uses safe development defaults from `.env.example`. Keep real
secrets in an uncommitted `.env` file or in host-managed secrets.

## Vapor References

- [Vapor Documentation](https://docs.vapor.codes)
- [Vapor Docker Deployment](https://docs.vapor.codes/deploy/docker/)
- [Vapor Environment](https://docs.vapor.codes/basics/environment/)

## Deployment

- [AWS Lightsail deployment plan](AWS_DEPLOYMENT.md)
