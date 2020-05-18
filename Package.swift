// swift-tools-version:5.1
//
//  Package.swift
//  SwiftyFan
//
//  Created by Serhii Mumriak on 29.01.2020.
//

import PackageDescription

let package = Package(
    name: "SwiftyFan",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(name: "SwiftyFan", targets: ["SwiftyFan"])
    ],
    dependencies: [
        .package(path: "./TinyFoundation"),
        .package(path: "./AppKid"),
        .package(path: "./CairoGraphics"),
        .package(path: "./ContentAnimation"),
        .package(path: "./SharedSystemLibs"),
        .package(path: "./Volcano")
    ],
    targets: [
        .target(
            name: "SwiftyFan",
            dependencies: [
                "AppKid",
                "CairoGraphics",
                "ContentAnimation",
                "TinyFoundation",
                "Volcano"
            ]
        ),
        .testTarget(
            name: "SwiftyFanTests",
            dependencies: ["SwiftyFan"]
        )
    ]
)
