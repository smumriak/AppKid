// swift-tools-version:5.3
//
//  Package.swift
//  Volcano
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import PackageDescription

let package = Package(
    name: "Volcano",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "Volcano", type: .dynamic, targets: ["Volcano"]),
    ],
    dependencies: [
        .package(path: "../SharedSystemLibs"),
        .package(path: "../TinyFoundation"),
        .package(name: "cglm", url: "https://github.com/recp/cglm", .branch("master")),
        .package(path: "../SimpleGLM"),
    ],
    targets: [
        .target(
            name: "Volcano",
            dependencies: [
                .product(name: "CVulkan", package: "SharedSystemLibs"),
                .product(name: "CXlib", package: "SharedSystemLibs"),
                .product(name: "TinyFoundation", package: "TinyFoundation"),
                .product(name: "cglm", package: "cglm"),
                .product(name: "SimpleGLM", package: "SimpleGLM"),
            ]
        ),
    ]
)
