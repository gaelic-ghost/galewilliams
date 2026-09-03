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
- Backups: intentionally deferred while PostgreSQL backup and restore options
  are researched. No automated backup system is selected or configured yet.

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
- A managed Turnstile widget restricted to `galewilliams.com`, with its public
  site key and private secret provided to the app separately.
- An edge rate-limit rule for the contact POST when the active Cloudflare plan
  supports method matching.
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
SITE_ORIGIN
ADMIN_USERNAME
ADMIN_PASSWORD
ADMIN_CSRF_SECRET
TURNSTILE_SITE_KEY
TURNSTILE_SECRET_KEY
TURNSTILE_EXPECTED_HOSTNAME
CONTACT_FORM_SECRET
LOG_LEVEL
```

`CONTACT_FORM_SECRET` must be a separate random value containing at least 32
characters. Do not reuse `ADMIN_CSRF_SECRET`. Keep
`CONTACT_CLIENT_IP_HEADER` unset until the origin has been restricted to trusted
Cloudflare traffic; accepting a client-IP header from an origin reachable by
arbitrary clients would let callers choose their own rate-limit identity. Once
that boundary is verified, set it to `CF-Connecting-IP`.

The SES notification slice will add:

```sh
AWS_REGION
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
SES_FROM_EMAIL
LEAD_NOTIFICATION_TO_EMAIL
```

Use host-managed secrets or a root-owned `.env` on the Lightsail instance. Do
not commit production secrets. The public Turnstile site key is recorded in
`.env.example` and is the production Compose default; the corresponding
`TURNSTILE_SECRET_KEY` must never be committed or put into browser code.

### Contact Secrets In Tagged Deployments

GitHub Actions is the source of truth for `TURNSTILE_SECRET_KEY` and
`CONTACT_FORM_SECRET`. Both names were confirmed present in the **production
environment** on 2026-09-03, with no repository-level copies remaining; their
values were not read or verified. The deploy job already references that
environment, so no workflow change is needed to consume them at this scope. See
[GitHub's secret configuration instructions](https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-secrets).

For a tagged release, the deployment workflow:

1. Checks out the same tag used to build the image and transfers its production
   Compose file and contact-secret installer over SSH.
2. Validates both secrets in the runner, then streams them through encrypted SSH
   standard input. It never puts secret values in command arguments, artifacts,
   or a transferred temporary file.
3. Replaces only those two assignments in `/srv/galewilliams/.env`, preserving
   the other settings. The replacement is atomic, root-owned, and mode `0600`.
   Temporary replacement files are created in the same protected destination
   and removed on failure. Existing multiline dotenv values are rejected without
   modification rather than risking corruption.
4. Validates and installs the tag's Compose file before the existing migration
   and runtime activation steps. This is necessary for new environment variables
   to reach the app, worker, and scheduler containers.

Both secrets are required by this deployment path. Blank values, surrounding
whitespace, control characters, or a signing secret shorter than 32 bytes stop
the deployment before runtime activation. Use a distinct, cryptographically
random signing secret; do not reuse an admin or Turnstile secret. Quote and dollar
characters are escaped for [Compose interpolation](https://docs.docker.com/compose/how-tos/environment-variables/variable-interpolation/).
Never run `contact-secrets.py emit` on its own: its output is exclusively for
the SSH pipe. Do not print production `.env` or expanded Compose configuration.

Changing a GitHub secret does not update running containers immediately. It is
applied on the next tagged deployment. Configuration installation precedes the
migration: if later deployment steps fail, the running containers retain their
old environment, while the host `.env` contains the newly installed secrets.
Image rollback does not roll secrets back. See the recovery gate below before
making any credential rotation that invalidates an old credential immediately.

The application's missing-configuration behavior still disables the form safely,
but this workflow will not silently turn a missing GitHub secret into a disabled
form deployment. An intentional Upwork-only deployment requires an explicitly
reviewed configuration change. No AWS Secrets Manager integration or Mac SSH
access is required for the GitHub-driven path.

## First Deployment Runbook

1. Create the Lightsail instance in one chosen AWS region.
2. Attach a static IP.
3. Add a restricted SSH key for deployment.
4. Install Docker and the Docker Compose plugin.
5. Clone the repository or copy a release artifact to the instance.
6. Create a production `.env` on the instance with database and admin secrets.
7. Confirm that the managed Turnstile widget containing site key
   `0x4AAAAAAEkHuCcDfzybZSUB` allows `galewilliams.com`. Place its corresponding
   secret in GitHub Actions as `TURNSTILE_SECRET_KEY`, and store a distinct
   random `CONTACT_FORM_SECRET` alongside it. Tagged deployments install both
   into the host environment as described above. For manual host provisioning,
   the app leaves the form unavailable when either secret is missing.
8. Build the image on the instance with `docker compose build`.
9. Start PostgreSQL with `docker compose up -d db`.
10. Do not deploy a production schema migration until the deferred PostgreSQL backup-and-restore plan has been selected, implemented, and verified. A Lightsail snapshot alone is not a tested database-restore procedure.
11. Run migrations with `docker compose run migrate`. Keep migrations forward-compatible: a release may add compatible schema, but destructive schema removal requires a separate later release after rollback is no longer needed.
12. Start the app, notifications worker, and notification reconciler with `docker compose up -d app worker scheduler`.
13. Start Caddy with `docker compose up -d caddy`.
14. Verify `http://<static-ip>/api/health` and `http://<static-ip>/api/ready`.
15. Point Cloudflare DNS at the static IP and set SSL/TLS mode to Full (strict).
16. Configure the contact endpoint edge rate limit supported by the active
    Cloudflare plan. Prefer matching `POST /contact`, counting by source IP,
    and challenging or blocking after five attempts in ten minutes. Plans that
    cannot match the HTTP method or use a ten-minute counting period must rely
    on Turnstile and the application limiter rather than applying an unsafe
    path-wide rule that could impede ordinary contact-page views.
17. Verify `https://galewilliams.com/api/health` and `https://galewilliams.com/api/ready`.
18. Submit one secondary inquiry through the production widget and confirm its
    persisted record and SES notification.
19. Create a first Lightsail snapshot after the deploy is verified.

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
- `/api/ready` confirms that the deployed web process can reach PostgreSQL before the site is treated as ready for contact intake.
- `/contact` presents Upwork as the primary project path and loads Turnstile
  from `https://challenges.cloudflare.com` without a CSP error.
- A valid secondary inquiry saves one lead; invalid, replayed, expired, and
  unavailable Turnstile checks save and email nothing.
- Application rate limits apply independently to source IP and normalized
  email (five attempts per ten minutes for each). Rotating one must not reset
  the other's quota. Until the trusted client-IP boundary is configured,
  visitors behind the same proxy address may share the IP quota.
- Both `/contact` and `/contact/` allow the widget script and frame. Siteverify
  configuration/provider failures use the unavailable response and error
  telemetry, distinct from rejected visitor tokens; see
  [Cloudflare's error code reference](https://developers.cloudflare.com/turnstile/get-started/server-side-validation/#error-codes-reference).
- The edge rate-limit rule is verified against `POST /contact` without
  limiting ordinary `GET /contact` page views.
- `/admin/leads` requires owner credentials.
- The Redis notifications worker records a successful SES message ID or a
  descriptive failed-delivery state for every queued lead notification.
- SES test email reaches Gale's mailbox.

## Monitoring And Recovery

Keep two separate public checks:

- `/api/health` answers only whether the Vapor web process is running.
- `/api/ready` also verifies PostgreSQL access, so it is the check that determines whether the site can durably accept contact intake.

External uptime monitoring is intentionally deferred. The two endpoints are
available for an eventual independent monitor, but no monitor or alert provider
is configured yet. Do not expose queue, database, SES, credential, or
lead-detail diagnostics through a public health response.

Before a release with a schema migration:

1. Select, implement, and verify the deferred PostgreSQL backup-and-restore
   plan before the migration is eligible for production.
2. Run the candidate migration before changing `IMAGE_TAG`.
3. Confirm `/api/health` and `/api/ready` after activation.

For a production incident:

1. Check `/api/health`, `/api/ready`, and the Compose service status.
2. If the web process is healthy but readiness fails, investigate PostgreSQL
   before treating the contact form as available.
3. If Redis is unavailable before submission, the secondary form rejects the
   inquiry without persisting it because rate limiting is fail-closed. If Redis
   queueing or SES fails after persistence, the lead retains a durable
   notification failure state; restore those dependencies and let the
   reconciler return pending notification records to the queue.
4. Restore runtime services to the prior image only when the migration remains
   forward-compatible. A destructive migration requires a tested database
   restore rather than an image-tag rollback; do not ship one before the
   deferred backup-and-restore plan exists.

## References

- [Amazon Lightsail pricing](https://aws.amazon.com/lightsail/pricing/)
- [Amazon SES domain identities](https://docs.aws.amazon.com/ses/latest/dg/creating-identities.html)
- [Amazon SES production access](https://docs.aws.amazon.com/ses/latest/dg/request-production-access.html)
- [Cloudflare Turnstile setup](https://developers.cloudflare.com/turnstile/get-started/)
- [Cloudflare Turnstile server-side validation](https://developers.cloudflare.com/turnstile/get-started/server-side-validation/)
- [Cloudflare rate-limiting rules](https://developers.cloudflare.com/waf/rate-limiting-rules/)
- [Vapor Docker deployment](https://docs.vapor.codes/deploy/docker/)
