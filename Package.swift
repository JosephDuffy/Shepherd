// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Shepherd",
    platforms: [
        .macOS(.v10_10), .iOS(.v8), .tvOS(.v9), .watchOS(.v2),
    ],
    products: [
        .library(name: "Shepherd", targets: ["Shepherd"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", from: "2.0.0"), // dev
        .package(url: "https://github.com/Quick/Nimble.git", from: "8.0.0"), // dev
        .package(url: "https://github.com/danger/swift.git", from: "1.0.0"), // dev
        .package(url: "https://github.com/Realm/SwiftLint", from: "0.32.0"), // dev
        .package(url: "https://github.com/f-meloni/Rocket", from: "0.1.0"), // dev
    ],
    targets: [
        .target(name: "Shepherd"),
        .testTarget(name: "ShepherdTests", dependencies: ["Shepherd", "Quick", "Nimble"]), // dev
    ],
    swiftLanguageVersions: [.v5]
)
