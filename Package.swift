// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReviewKit",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ReviewKit",
            targets: ["ReviewKit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/wiencheck/BoldButton", branch: "master"),
        .package(url: "https://github.com/wiencheck/OverlayPresentable", branch: "master"),
        .package(url: "https://github.com/wiencheck/AppConfiguration", branch: "master"),
        .package(url: "https://github.com/wiencheck/SwiftPropertyWrappers", branch: "master")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ReviewKit",
            dependencies: ["BoldButton", "OverlayPresentable", "AppConfiguration", "SwiftPropertyWrappers"]),
        .testTarget(
            name: "ReviewKitTests",
            dependencies: ["ReviewKit"]),
    ]
)
