// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PulseCore",
    platforms: [
        .iOS(.v15),
        .tvOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PulseCore",
            targets: ["PulseCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/realm/realm-swift", exact: "10.42.0"),
        .package(url: "https://github.com/kefaxoo/friendly-urlsession", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PulseCore",
            dependencies: [
                .product(name: "Realm", package: "realm-swift"),
                .product(name: "RealmSwift", package: "realm-swift"),
                .product(name: "FriendlyURLSession", package: "friendly-urlsession")
            ]
        )
    ]
)
