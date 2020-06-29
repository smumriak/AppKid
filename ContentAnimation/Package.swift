// swift-tools-version:5.3
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
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "ContentAnimation", type: .dynamic, targets: ["ContentAnimation"])
    ],
    dependencies: [
        .package(path: "../SharedSystemLibs"),
        .package(path: "../TinyFoundation"),
        .package(path: "../CairoGraphics")
    ],
    targets: [
        .target(
            name: "ContentAnimation",
            dependencies: [
                .product(name: "CairoGraphics", package: "CairoGraphics"),
                .product(name: "TinyFoundation", package: "TinyFoundation"),
                .product(name: "CVulkan", package: "SharedSystemLibs")
            ]
        )
    ]
)
