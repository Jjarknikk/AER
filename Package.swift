// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AER",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "AERCore", targets: ["AERCore"]),
        .executable(name: "aer-sim", targets: ["aer-sim"]),
        .executable(name: "AERMac", targets: ["AERMac"])
    ],
    targets: [
        .target(name: "AERCore"),
        .executableTarget(name: "aer-sim", dependencies: ["AERCore"]),
        .executableTarget(
            name: "AERMac",
            dependencies: ["AERCore"],
            resources: [.process("Resources")]
        ),
        .testTarget(name: "AERCoreTests", dependencies: ["AERCore"])
    ]
)
