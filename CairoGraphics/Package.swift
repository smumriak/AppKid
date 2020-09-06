// swift-tools-version:5.3
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
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "CairoGraphics", type: .dynamic, targets: ["CairoGraphics"]),
    ],
    dependencies: [
        .package(path: "../SharedSystemLibs"),
        .package(path: "../TinyFoundation"),
        .package(name: "cglm", url: "https://github.com/smumryak/cglm", .branch("master")),
    ],
    targets: [
        .target(
            name: "CairoGraphics",
            dependencies: [
                .product(name: "CCairo", package: "SharedSystemLibs"),
                .product(name: "CPango", package: "SharedSystemLibs"),
                .product(name: "TinyFoundation", package: "TinyFoundation"),
                .product(name: "cglm", package: "cglm"),
            ]
        ),
    ]
)
