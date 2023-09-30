// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PulseUIComponents",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PulseUIComponents",
            // swiftlint:disable trailing_comma
            targets: ["PulseUIComponents"]),
            // swiftlint:enable trailing_comma
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit", exact: "5.0.1"),
        .package(url: "https://github.com/kefaxoo/ESTMusicIndicator", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PulseUIComponents",
            dependencies: [
                .product(name: "ESTMusicIndicator", package: "ESTMusicIndicator")
            ]
        )
    ]
)
