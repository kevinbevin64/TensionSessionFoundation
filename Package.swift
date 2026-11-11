// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let settings: [SwiftSetting] = [
    .swiftLanguageMode(.v6),
    .defaultIsolation(MainActor.self),
    .enableUpcomingFeature("ApproachableConcurrency"),
]

let package = Package(
    name: "TensionSessionFoundation",
    platforms: [
        .iOS(.v26),
        .watchOS(.v26)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TensionSessionFoundation",
            targets: ["TensionSessionFoundation"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "TensionSessionFoundation",
            dependencies: [
                .product(name: "DequeModule", package: "swift-collections"),
            ],
            swiftSettings: settings
        ),
        .testTarget(
            name: "TensionSessionFoundationTests",
            dependencies: ["TensionSessionFoundation"],
            swiftSettings: settings
        ),
    ]
)
