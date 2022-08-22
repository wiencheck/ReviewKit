// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReviewKit",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ReviewKit",
            targets: ["ReviewKit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/wiencheck/BoldButton", from: "0.3.7"),
        .package(url: "https://github.com/wiencheck/OverlayPresentable", from: "0.0.1"),
        .package(url: "https://github.com/wiencheck/AppConfiguration", from: "1.0.3")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ReviewKit",
            dependencies: ["BoldButton", "OverlayPresentable", "AppConfiguration"]),
        .testTarget(
            name: "ReviewKitTests",
            dependencies: ["ReviewKit"]),
    ]
)
