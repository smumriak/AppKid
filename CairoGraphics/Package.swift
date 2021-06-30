// swift-tools-version:5.5
//
//  Package.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 11.05.2020.
//

import PackageDescription

let package = Package(
    name: "CairoGraphics",
    platforms: [
        .macOS(.v11),
    ],
    products: [
        .library(name: "CairoGraphics", type: .dynamic, targets: ["CairoGraphics"]),
        .library(name: "STBImage", type: .static, targets: ["STBImageRead", "STBImageWrite", "STBImageResize"]),
        .library(name: "STBImageRead", type: .static, targets: ["STBImageRead"]),
        .library(name: "STBImageWrite", type: .static, targets: ["STBImageWrite"]),
        .library(name: "STBImageResize", type: .static, targets: ["STBImageResize"]),
    ],
    dependencies: [
        .package(path: "../SharedSystemLibs"),
        .package(path: "../TinyFoundation"),
        .package(path: "../SimpleGLM"),
        .package(name: "cglm", url: "https://github.com/recp/cglm", .branch("master")),
    ],
    targets: [
        .target(
            name: "CairoGraphics",
            dependencies: [
                .product(name: "CCairo", package: "SharedSystemLibs"),
                .product(name: "CPango", package: "SharedSystemLibs"),
                .product(name: "TinyFoundation", package: "TinyFoundation"),
                .product(name: "cglm", package: "cglm"),
                .product(name: "SimpleGLM", package: "SimpleGLM"),
                .target(name: "STBImageRead"),
                .target(name: "STBImageWrite"),
                .target(name: "STBImageResize"),
            ]
        ),
        .target(name: "STBImageRead", path: "./SwiftSTB/Sources/STBImageRead"),
        .target(name: "STBImageWrite", path: "./SwiftSTB/Sources/STBImageWrite"),
        .target(name: "STBImageResize", path: "./SwiftSTB/Sources/STBImageResize"),
        .testTarget(
            name: "CairoGraphicsTests",
            dependencies: ["CairoGraphics"]
        ),
    ]
)
