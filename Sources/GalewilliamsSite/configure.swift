import Fluent
import FluentPostgresDriver
import Leaf
import Vapor

func configure(_ app: Application) throws {
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.views.use(.leaf)
    app.leaf.cache.isEnabled = app.environment.isRelease

    try configureDatabase(app)
    try routes(app)
}

private func configureDatabase(_ app: Application) throws {
    app.databases.use(
        .postgres(
            configuration: .init(
                hostname: Environment.get("DATABASE_HOST") ?? "localhost",
                port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? 5432,
                username: Environment.get("DATABASE_USERNAME") ?? "galewilliams",
                password: Environment.get("DATABASE_PASSWORD") ?? "galewilliams",
                database: Environment.get("DATABASE_NAME") ?? "galewilliams_site",
                tls: .prefer(try .init(configuration: .clientDefault))
            )
        ),
        as: .psql
    )
}
