// swift-tools-version:5.3
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
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "SwiftXlib", type: .static, targets: ["SwiftXlib"]),
    ],
    dependencies: [
        .package(path: "../SharedSystemLibs"),
        .package(path: "../TinyFoundation"),
    ],
    targets: [
        .target(
            name: "SwiftXlib",
            dependencies: [
                .product(name: "CXlib", package: "SharedSystemLibs"),
                .product(name: "TinyFoundation", package: "TinyFoundation"),
            ]
        ),
        .testTarget(
            name: "SwiftXlibTests",
            dependencies: ["SwiftXlib"]),
    ]
)
