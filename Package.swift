// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SnackbarKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "SnackbarKit",
            targets: ["SnackbarKit"]
        )
    ],
    targets: [
        .target(
            name: "SnackbarKit"
        ),
        .testTarget(
            name: "SnackbarKitTests",
            dependencies: ["SnackbarKit"]
        )
    ]
)
