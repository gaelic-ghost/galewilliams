// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "GalewilliamsSite",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .executable(name: "GalewilliamsSite", targets: ["GalewilliamsSite"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/queues-redis-driver.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/redis.git", from: "4.0.0"),
        .package(url: "https://github.com/awslabs/aws-sdk-swift.git", from: "1.7.0"),
    ],
    targets: [
        .executableTarget(
            name: "GalewilliamsSite",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Leaf", package: "leaf"),
                .product(name: "AWSSES", package: "aws-sdk-swift"),
                .product(name: "QueuesRedisDriver", package: "queues-redis-driver"),
                .product(name: "Redis", package: "redis"),
                .product(name: "Vapor", package: "vapor"),
            ]
        ),
        .testTarget(
            name: "GalewilliamsSiteTests",
            dependencies: [
                "GalewilliamsSite",
                .product(name: "Vapor", package: "vapor"),
                .product(name: "VaporTesting", package: "vapor"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
