// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "TokenTicker",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "TokenTicker",
            path: "TokenTicker",
            exclude: ["Info.plist"],
            // Link Info.plist into the binary's __TEXT,__info_plist section so
            // Bundle.main.infoDictionary reflects it at runtime — matches the fix in
            // molty-meter's Package.swift (see that repo for the v1.3-displayed-while-
            // actually-v1.5 bug this prevents). TokenTicker doesn't show a version in
            // its UI yet, but this makes the source of truth available if/when it does.
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__info_plist",
                    "-Xlinker", "TokenTicker/Info.plist"
                ])
            ]
        )
    ]
)
