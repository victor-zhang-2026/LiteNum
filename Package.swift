// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LiteNum",
    platforms: [.macOS(.v13)],
    products: [.executable(name: "LiteNum", targets: ["LiteNum"])],
    targets: [
        .target(name: "LiteNumCore"),
        .executableTarget(name: "LiteNum", dependencies: ["LiteNumCore"]),
        .testTarget(name: "LiteNumCoreTests", dependencies: ["LiteNumCore"])
    ],
    swiftLanguageModes: [.v5]
)
