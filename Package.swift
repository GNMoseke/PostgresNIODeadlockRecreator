// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FluentDatabaseApp",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .executable(name: "FluentDBReproducer", targets: ["Run"]),
        .library(
            name: "FluentDatabaseApp",
            targets: ["FluentDatabaseApp"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "FluentDatabaseApp",
            dependencies: [.product(name: "Vapor", package: "vapor"),
                           .product(name: "Fluent", package: "fluent"),
                               .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),]),
        .testTarget(
            name: "FluentDatabaseAppTests",
            dependencies: ["FluentDatabaseApp"]),
        .executableTarget(name: "Run", dependencies: ["FluentDatabaseApp"]),
    ]
)
