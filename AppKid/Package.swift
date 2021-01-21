// swift-tools-version:5.3
//
//  Package.swift
//  AppKid
//
//  Created by Serhii Mumriak on 11.05.2020.
//

import PackageDescription

let package = Package(
    name: "AppKid",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "AppKid", type: .dynamic, targets: ["AppKid"]),
    ],
    dependencies: [
        .package(path: "../SharedSystemLibs"),
        .package(path: "../TinyFoundation"),
        .package(path: "../CairoGraphics"),
        .package(path: "../ContentAnimation"),
        .package(path: "../Volcano"),
        .package(name: "cglm", url: "https://github.com/recp/cglm", .branch("master")),
        .package(path: "../SimpleGLM"),
        .package(path: "../SwiftXlib"),
    ],
    targets: [
        .target(
            name: "AppKid",
            dependencies: [
                .product(name: "CXlib", package: "SharedSystemLibs"),
                .product(name: "CVulkan", package: "SharedSystemLibs"),
                .product(name: "CairoGraphics", package: "CairoGraphics"),
                .product(name: "ContentAnimation", package: "ContentAnimation"),
                .product(name: "TinyFoundation", package: "TinyFoundation"),
                .product(name: "Volcano", package: "Volcano"),
                .product(name: "cglm", package: "cglm"),
                .product(name: "SimpleGLM", package: "SimpleGLM"),
                .product(name: "SwiftXlib", package: "SwiftXlib"),
            ],
            exclude: [
                "Resources/FragmentShader.volcano",
                "Resources/VertexShader.volcano",
            ],
            resources: [
                .copy("Resources/FragmentShader.spv"),
                .copy("Resources/VertexShader.spv"),
            ]
        ),
    ]
)
