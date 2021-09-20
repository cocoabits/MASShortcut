// swift-tools-version:5.4

import PackageDescription

let package = Package(
    name: "MASShortcut",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v10_11),
    ],
    products: [
        .library(name: "MASShortcut",
                 targets: ["MASShortcut"])
    ],
    targets: [
        .target(
            name: "MASShortcut",
            path: "Framework",
            exclude: [
                "Model/MASShortcutTests.m",
                "Monitoring/MASHotKeyTests.m",
                "Monitoring/MASShortcutMonitorTests.m",
                "User Defaults Storage/MASDictionaryTransformerTests.m",
                "User Defaults Storage/MASShortcutBinderTests.m",
                "Info.plist",
                "MASShortcut.modulemap",
                "Prefix.pch"
            ],
            resources: [
                .process("Resources")
            ],
            publicHeadersPath: "include"
        )
    ],
    swiftLanguageVersions: [.v5]
)
