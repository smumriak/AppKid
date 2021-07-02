// swift-tools-version:5.5
//
//  Package.swift
//  ContentAnimation
//
//  Created by Serhii Mumriak on 12.05.2020.
//

import PackageDescription

let package = Package(
    name: "ContentAnimation",
    platforms: [
        .macOS(.v11),
    ],
    products: [
        .library(name: "ContentAnimation", type: .dynamic, targets: ["ContentAnimation"]),
    ],
    dependencies: [
        .package(path: "../SharedSystemLibs"),
        .package(path: "../TinyFoundation"),
        .package(path: "../CairoGraphics"),
        .package(path: "../Volcano"),
        .package(path: "../SimpleGLM"),
        .package(path: "../Tools/glslImporter"),
    ],
    targets: [
        .target(
            name: "ContentAnimation",
            dependencies: [
                .product(name: "CairoGraphics", package: "CairoGraphics"),
                .product(name: "TinyFoundation", package: "TinyFoundation"),
                .product(name: "Volcano", package: "Volcano"),
                .product(name: "CVulkan", package: "SharedSystemLibs"),
                .product(name: "SimpleGLM", package: "SimpleGLM"),
                .target(name: "LayerRenderingData"),
            ],
            exclude: [
                "Resources/ShaderSources",
            ],
            resources: [
                .copy("Resources/ShaderBinaries"),
            ]
        ),
        .target(
            name: "LayerRenderingData",
            dependencies: [
                .product(name: "SimpleGLM", package: "SimpleGLM"),
            ]
        ),
    ]
)
