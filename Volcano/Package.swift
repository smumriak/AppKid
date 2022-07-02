// swift-tools-version:5.5
//
//  Package.swift
//  Volcano
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import PackageDescription
import Foundation

let tinyFoundationDependency: PackageDescription.Package.Dependency
let simpleGLMDependency: PackageDescription.Package.Dependency
let swiftXlibDependency: PackageDescription.Package.Dependency

// if ProcessInfo.processInfo.environment["APPKID_LOCAL_BUILD"] == nil {
//     tinyFoundationDependency = .package(url: "https://github.com/smumriak/TinyFoundation", branch: "main")
//     simpleGLMDependency = .package(url: "https://github.com/smumriak/SimpleGLM", branch: "main")
//     swiftXlibDependency = .package(url: "https://github.com/smumriak/SwiftXlib", branch: "main")
// } else {
tinyFoundationDependency = .package(path: "../TinyFoundation")
simpleGLMDependency = .package(path: "../SimpleGLM")
swiftXlibDependency = .package(path: "../SwiftXlib")
// }

let package = Package(
    name: "Volcano",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .library(name: "CVulkan", targets: ["CVulkan"]),
        .library(name: "Volcano", type: .dynamic, targets: ["Volcano"]),
        .library(name: "VulkanMemoryAllocatorAdapted", type: .static, targets: ["VulkanMemoryAllocatorAdapted"]),
        .executable(name: "vkthings", targets: ["vkthings"]),
        .executable(name: "volcanosl", targets: ["VolcanoSL"]),
        .plugin(name: "VolcanoSLPlugin", targets: ["VolcanoSLPlugin"]),
    ],
    dependencies: [
        tinyFoundationDependency,
        simpleGLMDependency,
        swiftXlibDependency,
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "1.0.0")),
        .package(url: "https://github.com/MaxDesiatov/XMLCoder.git", from: "0.13.1"),
        .package(url: "https://github.com/apple/swift-tools-support-core", branch: "main"),
    ],
    targets: [
        .systemLibrary(
            name: "CVulkan",
            pkgConfig: "vulkan",
            providers: [
                .apt(["vulkan-sdk libwayland-dev libx11-dev"]),
            ]
        ),
        .systemLibrary(
            name: "CClang",
            pkgConfig: "clang",
            providers: [
                .apt(["libclang-12-dev"]),
            ]
        ),
        .target(
            name: "Volcano",
            dependencies: [
                "CVulkan",
                .product(name: "CXlib", package: "SwiftXlib"),
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
                .define("VOLCANO_PLATFORM_APPLE_METAL", .when(platforms: [.iOS, .macOS])),
                .define("VOLCANO_PLATFORM_WINDOWS", .when(platforms: [.windows])),
                .define("VOLCANO_PLATFORM_ANDROID", .when(platforms: [.android])),
            ]
        ),
        .target(
            name: "VulkanMemoryAllocatorAdapted",
            dependencies: [
                "CVulkan",
            ],
            cSettings: [
                .unsafeFlags(["-Wno-nullability-completeness", "-std=gnu++17"]),
            ]
        ),
        .executableTarget(
            name: "vkthings",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "XMLCoder", package: "XMLCoder"),
            ]),
        .executableTarget(
            name: "VolcanoSL",
            dependencies: [
                "CClang",
                .product(name: "TinyFoundation", package: "TinyFoundation"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "TSCBasic", package: "swift-tools-support-core"),
            ],
            resources: [
                .copy("Resources/GLSLTypesInclude.h"),
            ]),
        .plugin(
            name: "VolcanoSLPlugin",
            capability: .buildTool(),
            dependencies: [.target(name: "VolcanoSL")]
        ),
    ]
)
