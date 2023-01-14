// swift-tools-version:5.7
//
//  Package.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import PackageDescription

let sysDependency: PackageDescription.Package.Dependency

// if ProcessInfo.processInfo.environment["APPKID_LOCAL_BUILD"] == nil {
//    sysDependency = .package(url: "https://github.com/smumriak/Sys", branch: "main")
// } else {
sysDependency = .package(path: "../Sys")
// }

let package = Package(
    name: "TinyFoundation",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .library(name: "TinyFoundation", targets: ["TinyFoundation"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections", .upToNextMinor(from: "1.0.0")),
        sysDependency,
    ],
    targets: [
        .target(
            name: "TinyFoundation",
            dependencies: [
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "LinuxSys", package: "Sys"),
                .target("HijackingHacks"),
            ]
        ),
        .target(name: "HijackingHacks"),
        .testTarget(
            name: "TinyFoundationTests",
            dependencies: ["TinyFoundation"]
        ),
    ]
)
