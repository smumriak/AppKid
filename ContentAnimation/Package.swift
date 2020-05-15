// swift-tools-version:5.1
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
        .package(path: "../CairoGraphics")
    ],
    targets: [
        .target(
            name: "ContentAnimation",
            dependencies: ["CairoGraphics"],
            linkerSettings: [
                .linkedLibrary("vulkan")
            ]
        )
    ]
)
