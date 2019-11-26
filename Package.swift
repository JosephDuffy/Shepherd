// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Shepherd",
    platforms: [
        .macOS(.v10_10), .iOS(.v8), .tvOS(.v9), .watchOS(.v2),
    ],
    products: [
        .library(name: "Shepherd", type: .dynamic, targets: ["Shepherd"]),
        .library(name: "DangerDeps", type: .dynamic, targets: ["DangerDependencies"]), // dev
    ],
    dependencies: [
        .package(url: "https://github.com/danger/swift.git", from: "2.0.0"), // dev
        .package(url: "https://github.com/JosephDuffy/SwiftChecksDangerPlugin.git", from: "0.1.0"), // dev
        .package(url: "https://github.com/Realm/SwiftLint", .upToNextMinor(from: "0.36.0")), // dev
        .package(url: "https://github.com/f-meloni/Rocket", from: "0.1.0"), // dev
    ],
    targets: [
        .target(name: "Shepherd"),
        .testTarget(name: "ShepherdTests", dependencies: ["Shepherd"]),
        .target(name: "DangerDependencies", dependencies: ["Danger", "swiftlint", "danger-swift", "SwiftChecksDangerPlugin"], path: "DangerDependencies"), // dev
    ],
    swiftLanguageVersions: [.v5]
)
