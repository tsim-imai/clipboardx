// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "ClipboardX",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "ClipboardX",
            targets: ["ClipboardX"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "ClipboardX",
            dependencies: [],
        ),
    ]
)
