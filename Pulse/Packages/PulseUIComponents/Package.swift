// swift-tools-version: 5.7
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
        .package(url: "https://github.com/SnapKit/SnapKit", exact: "5.6.0"),
        .package(url: "https://github.com/kefaxoo/ESTMusicIndicator", branch: "main"),
        .package(url: "https://github.com/SDWebImage/SDWebImage", exact: "5.18.0"),
        .package(path: "../PulseMedia")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PulseUIComponents",
            dependencies: ["ESTMusicIndicator", "SnapKit", "SDWebImage", "PulseMedia"]
        )
    ]
)
