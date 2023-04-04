// swift-tools-version:5.8
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
        .macOS(.v12),
    ],
    products: [
        .library(name: "CCairo", targets: ["CCairo"]),
        .library(name: "CPango", targets: ["CPango"]),
        .library(name: "CairoGraphics", type: .dynamic, targets: ["CairoGraphics"]),
        .library(name: "STBImage", type: .static, targets: ["STBImageRead", "STBImageWrite", "STBImageResize"]),
        .library(name: "STBImageRead", type: .static, targets: ["STBImageRead"]),
        .library(name: "STBImageWrite", type: .static, targets: ["STBImageWrite"]),
        .library(name: "STBImageResize", type: .static, targets: ["STBImageResize"]),
    ],
    dependencies: [
        .package(path: "../CCore"),
        .package(path: "../TinyFoundation"),
        .package(path: "../SimpleGLM"),
    ],
    targets: [
        .systemLibrary(
            name: "CCairo",
            pkgConfig: "cairo gobject-2.0",
            providers: [
                .apt(["libcairo2-dev"]),
                .brew(["cairo glib"]),
            ]
        ),
        .systemLibrary(
            name: "CPango",
            pkgConfig: "pango gobject-2.0",
            providers: [
                .apt(["libpango1.0-dev"]),
                .brew(["pango glib"]),
            ]
        ),
        .target(
            name: "CairoGraphics",
            dependencies: [
                "CCairo",
                "CPango",
                .product(name: "TinyFoundation", package: "TinyFoundation"),
                .product(name: "SimpleGLM", package: "SimpleGLM"),
                .target(name: "STBImageRead"),
                .target(name: "STBImageWrite"),
                .target(name: "STBImageResize"),
            ],
            swiftSettings: [
                .unsafeFlags(["-emit-module"]),
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
