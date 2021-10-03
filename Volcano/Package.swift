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
        .macOS(.v11),
    ],
    products: [
        .library(name: "Volcano", type: .dynamic, targets: ["Volcano"]),
        .library(name: "VulkanMemoryAllocatorAdapted", type: .static, targets: ["VulkanMemoryAllocatorAdapted"]),
        .library(name: "SwiftVMA", targets: ["SwiftVMA"]),
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
                .unsafeFlags(["-Xfrontend", "-enable-experimental-concurrency"]),
            ]
        ),
        .target(
            name: "VulkanMemoryAllocatorAdapted",
            dependencies: [
                .product(name: "CVulkan", package: "SharedSystemLibs"),
            ],
            cSettings: [
                .unsafeFlags(["-Wno-nullability-completeness"]),
            ]
        ),
        .target(
            name: "SwiftVMA",
            dependencies: [
                .product(name: "CVulkan", package: "SharedSystemLibs"),
                .target(name: "VulkanMemoryAllocatorAdapted"),
                .target(name: "Volcano"),
            ]
        ),
    ]
)
