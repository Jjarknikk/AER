// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AER",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "AERCore", targets: ["AERCore"]),
        .executable(name: "aer-sim", targets: ["aer-sim"])
    ],
    targets: [
        .target(name: "AERCore"),
        .executableTarget(name: "aer-sim", dependencies: ["AERCore"]),
        .testTarget(name: "AERCoreTests", dependencies: ["AERCore"])
    ]
)
