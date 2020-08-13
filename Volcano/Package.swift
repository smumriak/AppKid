// swift-tools-version:5.3
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
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "Volcano", type: .dynamic, targets: ["Volcano"])
    ],
    dependencies: [
        .package(path: "../SharedSystemLibs"),
        .package(path: "../TinyFoundation")
    ],
    targets: [
        .target(
            name: "Volcano",
            dependencies: [
                .product(name: "CVulkan", package: "SharedSystemLibs"),
                .product(name: "CX11", package: "SharedSystemLibs"),
                .product(name: "TinyFoundation", package: "TinyFoundation")
            ]
        )
    ]
)