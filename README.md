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

Start PostgreSQL and the app:

```sh
docker compose up db app
```

Run database migrations:

```sh
docker compose run migrate
```

The Compose file uses safe development defaults from `.env.example`. Keep real
secrets in an uncommitted `.env` file or in host-managed secrets.

## Vapor References

- [Vapor Documentation](https://docs.vapor.codes)
- [Vapor Docker Deployment](https://docs.vapor.codes/deploy/docker/)
- [Vapor Environment](https://docs.vapor.codes/basics/environment/)
