// swift-tools-version:5.5
//
//  Package.swift
//  AppKid
//
//  Created by Serhii Mumriak on 11.05.2020.
//

import PackageDescription
import Foundation

let tinyFoundationDependency: PackageDescription.Package.Dependency
let cairoGraphicsDependency: PackageDescription.Package.Dependency
let contentAnimationDependency: PackageDescription.Package.Dependency
let volcanoDependency: PackageDescription.Package.Dependency
let simpleGLMDependency: PackageDescription.Package.Dependency
let swiftXlibDependency: PackageDescription.Package.Dependency

if ProcessInfo.processInfo.environment["APPKID_LOCAL_BUILD"] == nil {
    tinyFoundationDependency = .package(url: "https://github.com/smumriak/TinyFoundation", branch: "main")
    cairoGraphicsDependency = .package(url: "https://github.com/smumriak/CairoGraphics", branch: "main")
    contentAnimationDependency = .package(url: "https://github.com/smumriak/ContentAnimation", branch: "main")
    volcanoDependency = .package(url: "https://github.com/smumriak/Volcano", branch: "main")
    simpleGLMDependency = .package(url: "https://github.com/smumriak/SimpleGLM", branch: "main")
    swiftXlibDependency = .package(url: "https://github.com/smumriak/SwiftXlib", branch: "main")
} else {
    tinyFoundationDependency = .package(path: "../TinyFoundation")
    cairoGraphicsDependency = .package(path: "../CairoGraphics")
    contentAnimationDependency = .package(path: "../ContentAnimation")
    volcanoDependency = .package(path: "../Volcano")
    simpleGLMDependency = .package(path: "../SimpleGLM")
    swiftXlibDependency = .package(path: "../SwiftXlib")
}

let package = Package(
    name: "AppKid",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .library(name: "AppKid", type: .dynamic, targets: ["AppKid"]),
    ],
    dependencies: [
        tinyFoundationDependency,
        cairoGraphicsDependency,
        contentAnimationDependency,
        volcanoDependency,
        simpleGLMDependency,
        swiftXlibDependency,
    ],
    targets: [
        .target(
            name: "AppKid",
            dependencies: [
                .product(name: "CairoGraphics", package: "CairoGraphics"),
                .product(name: "ContentAnimation", package: "ContentAnimation"),
                .product(name: "TinyFoundation", package: "TinyFoundation"),
                .product(name: "Volcano", package: "Volcano"),
                .product(name: "SimpleGLM", package: "SimpleGLM"),
                .product(name: "CXlib", package: "SwiftXlib"),
                .product(name: "SwiftXlib", package: "SwiftXlib"),
            ],
            swiftSettings: [
                .unsafeFlags(["-emit-module"]),
            ]
        ),
    ]
)
