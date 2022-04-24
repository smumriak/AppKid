// swift-tools-version:5.5
//
//  Package.swift
//  VolcanoSL
//
//  Created by Serhii Mumriak on 13.06.2021.
//

import PackageDescription
import Foundation

let tinyFoundationDependency: PackageDescription.Package.Dependency

if ProcessInfo.processInfo.environment["APPKID_LOCAL_BUILD"] == nil {
    tinyFoundationDependency = .package(url: "https://github.com/smumriak/TinyFoundation", branch: "main")
} else {
    tinyFoundationDependency = .package(path: "../TinyFoundation")
}

let package = Package(
    name: "VolcanoSL",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .executable(name: "volcanosl", targets: ["VolcanoSL"]),
        // .plugin(name: "VolcanoSLPlugin", targets: ["VolcanoSLPlugin"])
    ],
    dependencies: [
        tinyFoundationDependency,
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "1.0.0")),
    ],
    targets: [
        .executableTarget(
            name: "VolcanoSL",
            dependencies: [
                "CClang",
                .product(name: "TinyFoundation", package: "TinyFoundation"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            resources: [
                .copy("Resources/GLSLTypesInclude.h"),
            ]),
        // .plugin(
        //     name: "VolcanoSLPlugin",
        //     capability: .buildTool(),
        //     dependencies: [.target(name: "VolcanoSL")]
        // ),
        .systemLibrary(
            name: "CClang",
            pkgConfig: "clang",
            providers: [
                .apt(["libclang-dev"]),
            ]
        ),
        .testTarget(
            name: "VolcanoSLTests",
            dependencies: ["VolcanoSL"]),
    ]
)
