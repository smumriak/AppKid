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
        .macOS(.v11),
    ],
    products: [
        .library(name: "SwiftXlib", type: .dynamic, targets: ["SwiftXlib"]),
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
            ],
            swiftSettings: [
                .unsafeFlags(["-emit-module", "-emit-library"]),
            ]
        ),
        .testTarget(
            name: "SwiftXlibTests",
            dependencies: ["SwiftXlib"]),
    ]
)
