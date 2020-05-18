// swift-tools-version:5.1
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
            dependencies: ["CVulkan", "CX11", "TinyFoundation"])
    ]
)
