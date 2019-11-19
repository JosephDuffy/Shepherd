// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Shepherd",
    platforms: [
        .macOS(.v10_10), .iOS(.v8), .tvOS(.v9), .watchOS(.v2),
    ],
    products: [
        .library(name: "Shepherd", type: .dynamic, targets: ["Shepherd"]),
    ],
    dependencies: [
        .package(url: "https://github.com/danger/swift.git", from: "2.0.0"), // dev
        .package(url: "https://github.com/Realm/SwiftLint", from: "0.32.0"), // dev
        .package(url: "https://github.com/f-meloni/Rocket", from: "0.1.0"), // dev
    ],
    targets: [
        .target(name: "Shepherd"),
        .testTarget(name: "ShepherdTests", dependencies: ["Shepherd"]),
        .target(name: "CIDependencies", dependencies: ["Danger", "swiftlint", "danger-swift"], path: "Resources"), // dev
    ],
    swiftLanguageVersions: [.v5]
)
