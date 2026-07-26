# AWS Deployment Plan

This project will use AWS in the smallest useful shape first: Lightsail for the
Vapor app host, Cloudflare for DNS/TLS/proxying, and Amazon SES for outbound
lead notification email.

## Chosen First Production Shape

- Host: Amazon Lightsail Linux/Unix virtual server.
- Initial bundle: 2 GB RAM plan when available at the expected fixed monthly
  price.
- Runtime: Docker Compose on the instance.
- Database: PostgreSQL in the same Compose stack for the first production
  phase.
- Queue: Redis and one dedicated Vapor notifications worker in the same
  Compose stack.
- Public web edge: Caddy receives HTTP/HTTPS and proxies internally to Vapor.
- DNS and TLS edge: Cloudflare.
- Mailbox provider: iCloud can continue receiving `galewilliams.com` email.
- Transactional email: Amazon SES sends app notifications to Gale.
- Backups: Lightsail instance snapshots first; move database backups out of the
  instance before storing paid orders, licenses, or client portal data.

This is a conscious fixed-cost starting point, not the final scale shape. It is
meant to keep the first public deployment easy to operate while preserving a
clean migration path to managed PostgreSQL, App Runner, ECS, or another AWS
service later.

## Provisioned Foundation

Provisioned on 2026-07-25 in `us-east-2`:

- Lightsail instance: `galewilliams-prod` in `us-east-2a`.
- Host image: Ubuntu 24.04 LTS.
- Bundle: `small_3_0` — 2 GB RAM, 60 GB disk, and 3 TB monthly transfer at
  $12/month.
- Static IP: `galewilliams-prod-ip`, attached to the instance. Retrieve its
  current address with `aws lightsail get-static-ip --region us-east-2 --static-ip-name galewilliams-prod-ip` instead of copying an address into configuration.
- SES domain identity: `galewilliams.com`. It remains in the SES sandbox until
  DNS verification completes and production access is requested if external
  recipients are needed.

The account has two purpose-specific IAM users, with no credentials stored in
this repository:

- `galewilliams-lightsail-deployer` can operate this site's Lightsail resources
  in `us-east-2` and read SES status.
- `galewilliams-ses-runtime` can only send SES email from the
  `galewilliams.com` identity.

Create a runtime access key only when it can be installed in the instance's
root-owned deployment environment. Rotate it when access changes or a secret
may have been exposed.

## Why Lightsail First

Lightsail gives this project a predictable monthly bill and a simple deployment
surface: one small Linux server, one Docker Compose stack, Cloudflare in front,
and AWS SES for email. That fits the current site better than a multi-service
AWS architecture.

Use a managed Lightsail database later when one of these becomes true:

- lead or order data becomes important enough to separate from the app host;
- restore drills from instance snapshots feel too manual;
- uptime requirements increase;
- license keys, payments, or client accounts become production features.

## Baseline Architecture

```text
Visitor
  -> Cloudflare DNS/proxy/TLS
  -> Lightsail static IPv4 address
  -> Docker Compose Caddy service
  -> Docker Compose app service
  -> Docker Compose PostgreSQL service

Vapor app
  -> Redis notifications queue -> Vapor notifications worker -> Amazon SES
  -> Cloudflare/R2 later for downloadable release artifacts
```

## Required AWS Pieces

- Lightsail Linux/Unix instance.
- Static IP attached to the instance.
- Lightsail snapshots enabled or scheduled.
- SES domain identity for `galewilliams.com`.
- SES DKIM records added in Cloudflare DNS.
- SES production access request before relying on notifications for arbitrary
  recipients.
- Optional custom MAIL FROM domain such as `bounce.galewilliams.com`.

## Required Cloudflare Pieces

- DNS `A` or `AAAA` record pointing the app hostname to the Lightsail static IP.
- Cloudflare proxy/TLS enabled after the origin is reachable. Set SSL/TLS mode
  to Full (strict): Caddy automatically provisions and renews the public
  origin certificate after DNS points at the instance and ports 80/443 are open.
- SES DKIM records from AWS.
- SPF record merged safely with existing mail provider records.
- DMARC record if the domain does not already have one.

Keep iCloud MX records in place for inbound mailbox delivery unless Gale
explicitly chooses to move mailbox hosting.

## Application Environment

The production host must provide:

```sh
DATABASE_HOST
DATABASE_PORT
DATABASE_USERNAME
DATABASE_PASSWORD
DATABASE_NAME
REDIS_URL
SITE_DOMAIN
ADMIN_USERNAME
ADMIN_PASSWORD
LOG_LEVEL
```

The SES notification slice will add:

```sh
AWS_REGION
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
SES_FROM_EMAIL
LEAD_NOTIFICATION_TO_EMAIL
```

Use host-managed secrets or a root-owned `.env` on the Lightsail instance. Do
not commit production values.

## First Deployment Runbook

1. Create the Lightsail instance in one chosen AWS region.
2. Attach a static IP.
3. Add a restricted SSH key for deployment.
4. Install Docker and the Docker Compose plugin.
5. Clone the repository or copy a release artifact to the instance.
6. Create a production `.env` on the instance with database and admin secrets.
7. Build the image on the instance with `docker compose build`.
8. Start PostgreSQL with `docker compose up -d db`.
9. Run migrations with `docker compose run migrate`.
10. Start the app, notifications worker, and notification reconciler with `docker compose up -d app worker scheduler`.
11. Start Caddy with `docker compose up -d caddy`.
12. Verify `http://<static-ip>/api/health`.
13. Point Cloudflare DNS at the static IP and set SSL/TLS mode to Full (strict).
14. Verify `https://galewilliams.com/api/health`.
15. Create a first Lightsail snapshot after the deploy is verified.

## Cost Guardrails

- Use Lightsail fixed bundles for the app host.
- Keep Cloudflare DNS rather than moving DNS into Route 53.
- Set an AWS budget alert before enabling SES or additional services.
- Avoid adding load balancers, managed databases, or extra instances until the
  site has a concrete operational need.
- Revisit the database plan before enabling payments, licenses, or client
  accounts.

## Validation Checklist

- `swift test` passes locally before deploy.
- `scripts/repo-maintenance/validate-all.sh` passes locally before deploy.
- `docker compose config` passes locally.
- Production instance can build or pull the image.
- `docker compose run migrate` succeeds on production.
- `/api/health` returns `ok` through Cloudflare.
- `/contact` saves a lead.
- `/admin/leads` requires owner credentials.
- The Redis notifications worker records a successful SES message ID or a
  descriptive failed-delivery state for every queued lead notification.
- SES test email reaches Gale's mailbox.

## References

- [Amazon Lightsail pricing](https://aws.amazon.com/lightsail/pricing/)
- [Amazon SES domain identities](https://docs.aws.amazon.com/ses/latest/dg/creating-identities.html)
- [Amazon SES production access](https://docs.aws.amazon.com/ses/latest/dg/request-production-access.html)
- [Vapor Docker deployment](https://docs.vapor.codes/deploy/docker/)
