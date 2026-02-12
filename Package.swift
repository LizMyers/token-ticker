// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "TokenTicker",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "TokenTicker",
            path: "TokenTicker"
        )
    ]
)
