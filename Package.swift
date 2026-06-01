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
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "GalewilliamsSite",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Leaf", package: "leaf"),
                .product(name: "Vapor", package: "vapor"),
            ]
        ),
        .testTarget(
            name: "GalewilliamsSiteTests",
            dependencies: [
                "GalewilliamsSite",
                .product(name: "Vapor", package: "vapor"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
