// swift-tools-version:5.5
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
        .macOS(.v10_15),
    ],
    products: [
        .executable(name: "SwiftyFan", targets: ["SwiftyFan"]),
    ],
    dependencies: [
        .package(path: "./TinyFoundation"),
        .package(path: "./AppKid"),
        .package(path: "./CairoGraphics"),
        .package(path: "./ContentAnimation"),
        .package(path: "./SharedSystemLibs"),
        .package(path: "./Volcano"),
        .package(name: "cglm", url: "https://github.com/recp/cglm", .branch("master")),
        .package(path: "./SimpleGLM"),
        .package(name: "glslImporter", path: "./Tools/glslImporter"),
    ],
    targets: [
        .executableTarget(
            name: "SwiftyFan",
            dependencies: [
                .product(name: "AppKid", package: "AppKid"),
                .product(name: "CairoGraphics", package: "CairoGraphics"),
                .product(name: "ContentAnimation", package: "ContentAnimation"),
                .product(name: "TinyFoundation", package: "TinyFoundation"),
                .product(name: "Volcano", package: "Volcano"),
                .product(name: "cglm", package: "cglm"),
                .product(name: "SimpleGLM", package: "SimpleGLM"),
            ],
            resources: [
                .copy("Resources/AppIcon.png"),
            ]
        ),
        .testTarget(
            name: "SwiftyFanTests",
            dependencies: ["SwiftyFan"]
        ),
    ]
)
