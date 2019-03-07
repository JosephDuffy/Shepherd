// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Shepherd",
    products: [
        .library(name: "Shepherd", type: .dynamic, targets: ["Shepherd"]),
        .library(name: "DangerDeps", type: .dynamic, targets: ["DangerDeps"]), // dev
    ],
    dependencies: [
        .package(url: "https://github.com/JosephDuffy/danger-swift.git", from: "1.0.0"), // dev
        .package(url: "https://github.com/Realm/SwiftLint", from: "0.30.1"), // dev
        .package(url: "https://github.com/f-meloni/Rocket", from: "0.1.0"), // dev
    ],
    targets: [
        .target(name: "Shepherd", path: "Source"),
        .testTarget(name: "ShepherdTests", dependencies: ["Shepherd"], path: "Tests"),
        // A target to allow the DangerDeps library to be built
        .target(name: "DangerDeps", dependencies: ["Danger"], path: "Resources/", sources: ["DangerDeps.swift"]), // dev
    ]
)
