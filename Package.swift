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
    targets: [
        .target(name: "Shepherd"),
        .testTarget(name: "ShepherdTests", dependencies: ["Shepherd"]),
    ]
)
