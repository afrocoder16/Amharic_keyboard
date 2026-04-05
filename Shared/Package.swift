// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AmharicCore",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "AmharicCore",
            targets: ["AmharicCore"]
        ),
    ],
    targets: [
        .target(
            name: "AmharicCore",
            path: "Sources/AmharicCore",
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
