// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Shepherd",
    products: [
        .library(name: "Shepherd", type: .dynamic, targets: ["Shepherd"]),
    ],
    dependencies: [
        .package(url: "https://github.com/danger/swift.git", from: "2.0.0"), // dev
        .package(url: "https://github.com/Realm/SwiftLint", from: "0.32.0"), // dev
        .package(url: "https://github.com/f-meloni/Rocket", from: "0.1.0"), // dev
    ],
    targets: [
        .target(name: "Shepherd", path: "Source"),
        .testTarget(name: "ShepherdTests", dependencies: ["Shepherd"], path: "Tests"),
        .target(name: "CIDependencies", dependencies: ["Danger", "swiftlint", "danger-swift"], path: "Resources"), // dev
    ]
)
