// swift-tools-version:5.3
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
            ],
            resources: [
                .copy("Resources/AppIcon.png"),
                .copy("Resources/TriangleFragmentShader.frag"),
                .copy("Resources/TriangleFragmentShader.spv"),
                .copy("Resources/TriangleVertexShader.vert"),
                .copy("Resources/TriangleVertexShader.spv")
            ]
        ),
        .testTarget(
            name: "SwiftyFanTests",
            dependencies: ["SwiftyFan"]
        )
    ]
)
