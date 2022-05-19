// swift-tools-version:5.5
//
//  Package.swift
//  ContentAnimation
//
//  Created by Serhii Mumriak on 12.05.2020.
//

import PackageDescription
import Foundation

let tinyFoundationDependency: PackageDescription.Package.Dependency
let cairoGraphicsDependency: PackageDescription.Package.Dependency
let volcanoDependency: PackageDescription.Package.Dependency
let simpleGLMDependency: PackageDescription.Package.Dependency

if ProcessInfo.processInfo.environment["APPKID_LOCAL_BUILD"] == nil {
    tinyFoundationDependency = .package(url: "https://github.com/smumriak/TinyFoundation", branch: "main")
    cairoGraphicsDependency = .package(url: "https://github.com/smumriak/CairoGraphics", branch: "main")
    volcanoDependency = .package(url: "https://github.com/smumriak/Volcano", branch: "main")
    simpleGLMDependency = .package(url: "https://github.com/smumriak/SimpleGLM", branch: "main")
} else {
    tinyFoundationDependency = .package(path: "../TinyFoundation")
    cairoGraphicsDependency = .package(path: "../CairoGraphics")
    volcanoDependency = .package(path: "../Volcano")
    simpleGLMDependency = .package(path: "../SimpleGLM")
}

let package = Package(
    name: "ContentAnimation",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .library(name: "ContentAnimation", type: .dynamic, targets: ["ContentAnimation"]),
    ],
    dependencies: [
        tinyFoundationDependency,
        cairoGraphicsDependency,
        volcanoDependency,
        simpleGLMDependency,
        .package(url: "https://github.com/apple/swift-collections", .upToNextMinor(from: "1.0.0")),
    ],
    targets: [
        .target(
            name: "ContentAnimation",
            dependencies: [
                .product(name: "CairoGraphics", package: "CairoGraphics"),
                .product(name: "TinyFoundation", package: "TinyFoundation"),
                .product(name: "Volcano", package: "Volcano"),
                .product(name: "SimpleGLM", package: "SimpleGLM"),
                .target(name: "LayerRenderingData"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "OrderedCollections", package: "swift-collections"),
            ],
            exclude: [
                "Resources/ShaderSources",
            ],
            resources: [
                .copy("Resources/ShaderBinaries"),
            ],
            swiftSettings: [
                .unsafeFlags(["-emit-module"]),
            ],
            plugins: [
                // .plugin(name: "VolcanoSLPlugin", package: "Volcano"),
            ]
        ),
        .target(
            name: "LayerRenderingData",
            dependencies: [
                .product(name: "SimpleGLM", package: "SimpleGLM"),
            ]
        ),
        .testTarget(
            name: "ContentAnimationTests",
            dependencies: ["ContentAnimation"]
        ),
    ]
)
