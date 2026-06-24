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

The Compose file uses safe development defaults from `.env.example`. Keep real
secrets in an uncommitted `.env` file or in host-managed secrets.

## Vapor References

- [Vapor Documentation](https://docs.vapor.codes)
- [Vapor Docker Deployment](https://docs.vapor.codes/deploy/docker/)
- [Vapor Environment](https://docs.vapor.codes/basics/environment/)
