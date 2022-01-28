// swift-tools-version:5.5
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
        .macOS(.v12),
    ],
    products: [
        .library(name: "Volcano", type: .dynamic, targets: ["Volcano"]),
        .library(name: "VulkanMemoryAllocatorAdapted", type: .static, targets: ["VulkanMemoryAllocatorAdapted"]),
    ],
    dependencies: [
        .package(path: "../SharedSystemLibs"),
        .package(path: "../TinyFoundation"),
        .package(path: "../SimpleGLM"),
    ],
    targets: [
        .target(
            name: "Volcano",
            dependencies: [
                .product(name: "CVulkan", package: "SharedSystemLibs"),
                .product(name: "CXlib", package: "SharedSystemLibs"),
                .product(name: "TinyFoundation", package: "TinyFoundation"),
                .product(name: "SimpleGLM", package: "SimpleGLM"),
                .target(name: "VulkanMemoryAllocatorAdapted"),
            ],
            swiftSettings: [
                .unsafeFlags(["-emit-module"]),
                .define("VOLCANO_EXPERIMENTAL_DSL"),
                .define("VOLCANO_PLATFORM_LINUX", .when(platforms: [.linux])),
                .define("VOLCANO_PLATFORM_MACOS", .when(platforms: [.macOS])),
                .define("VOLCANO_PLATFORM_IOS", .when(platforms: [.iOS])),
                .define("VOLCANO_PLATFORM_WINDOWS", .when(platforms: [.windows])),
                .define("VOLCANO_PLATFORM_ANDROID", .when(platforms: [.android])),
            ]
        ),
        .target(
            name: "VulkanMemoryAllocatorAdapted",
            dependencies: [
                .product(name: "CVulkan", package: "SharedSystemLibs"),
            ],
            cSettings: [
                .unsafeFlags(["-Wno-nullability-completeness", "-std=gnu++17"]),
            ]
        ),
    ]
)
