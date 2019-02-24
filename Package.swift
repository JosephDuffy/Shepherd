// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Shepherd",
    products: [
        .library(name: "Shepherd", type: .dynamic, targets: ["Shepherd"]),
    ],
    dependencies: [
        .package(url: "https://github.com/danger/swift.git", from: "1.0.0"), // dev
    ],
    targets: [
        .target(name: "Shepherd", path: "Source"),
        .testTarget(name: "ShepherdTests", dependencies: ["Shepherd"], path: "Tests"),
        // Danger seems to look "DangerDeps": https://github.com/danger/swift/blob/master/Sources/RunnerLib/SPMDanger.swift
        .target(name: "DangerDeps", dependencies: ["Danger"], path: ".", sources: ["Dangerfile.swift"]), // dev
    ]
)