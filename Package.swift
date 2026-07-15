// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Neruna",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(name: "Neruna", path: "Sources/Neruna")
    ]
)
