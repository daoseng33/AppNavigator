// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppNavigator",
    products: [
        .library(
            name: "AppNavigator",
            targets: ["AppNavigator"]),
    ],
    dependencies: [
        .package(url: "https://github.com/devxoul/URLNavigator.git", .upToNextMajor(from: "2.5.1")),
    ],
    targets: [
        .target(
            name: "AppNavigator",
            dependencies: ["URLNavigator"]),
        .testTarget(
            name: "AppNavigatorTests",
            dependencies: ["AppNavigator"]
        ),
    ]
)
