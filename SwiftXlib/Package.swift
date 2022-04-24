// swift-tools-version:5.5
//
//  Package.swift
//  SwiftXlib
//
//  Created by Serhii Mumriak on 10.12.2020.
//

import PackageDescription

let package = Package(
    name: "SwiftXlib",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .library(name: "CXlib", targets: ["CXlib"]),
        .library(name: "SwiftXlib", type: .dynamic, targets: ["SwiftXlib"]),
    ],
    dependencies: [
        .package(path: "../SharedSystemLibs"),
        .package(path: "../TinyFoundation"),
    ],
    targets: [
        .systemLibrary(
            name: "CXlib",
            pkgConfig: "x11 xext xi xcb",
            providers: [
                .apt(["libx11-dev libxext-dev libxi-dev libwayland-dev libxcb1-dev"]),
                .brew(["xquartz"]),
            ]
        ),
        .target(
            name: "SwiftXlib",
            dependencies: [
                "CXlib",
                .product(name: "TinyFoundation", package: "TinyFoundation"),
            ],
            swiftSettings: [
                .unsafeFlags(["-emit-module"]),
            ]
        ),
        .testTarget(
            name: "SwiftXlibTests",
            dependencies: ["SwiftXlib"]),
    ]
)
