import Fluent
import FluentPostgresDriver
import Leaf
import QueuesRedisDriver
import Redis
import Vapor

func configure(_ app: Application) throws {
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.views.use(.leaf)
    app.leaf.cache.isEnabled = app.environment.isRelease

    try configureDatabase(app)
    try configureLeadNotifications(app)
    app.migrations.add(CreateLeadSubmissions())
    app.migrations.add(AddLeadSubmissionReviewFields())
    app.migrations.add(CreateLeadNotifications())
    try routes(app)
}

private func configureDatabase(_ app: Application) throws {
    try app.databases.use(
        .postgres(
            configuration: .init(
                hostname: Environment.get("DATABASE_HOST") ?? "localhost",
                port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? 5432,
                username: Environment.get("DATABASE_USERNAME") ?? "galewilliams",
                password: Environment.get("DATABASE_PASSWORD") ?? "development-password",
                database: Environment.get("DATABASE_NAME") ?? "galewilliams_site",
                tls: .prefer(.init(configuration: .clientDefault))
            )
        ),
        as: .psql
    )
}

private func configureLeadNotifications(_ app: Application) throws {
    let redisURL = Environment.get("REDIS_URL") ?? "redis://localhost:6379"
    app.redis.configuration = try .init(url: redisURL)
    try app.queues.use(.redis(url: redisURL))
    app.queues.add(LeadNotificationJob())
    app.queues
        .schedule(LeadNotificationReconciliationJob())
        .every(minutes: 5)
    app.leadNotificationEmailSender = SESLeadNotificationEmailSender()

    if app.environment.isRelease {
        do {
            _ = try LeadNotificationConfiguration.load()
        } catch {
            app.logger.warning("Lead notification delivery is configured with Redis, but the Amazon SES settings are incomplete. Contact submissions will still persist, while notification records remain undelivered until AWS_REGION, SES_FROM_EMAIL, and LEAD_NOTIFICATION_TO_EMAIL are configured. Cause: \(error.localizedDescription)")
        }
    }
}
