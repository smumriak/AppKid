// swift-tools-version:5.1
//
//  Package.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 11.05.2020.
//

import PackageDescription

let package = Package(
    name: "CairoGraphics",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "CairoGraphics", type: .dynamic, targets: ["CairoGraphics"])
    ],
    dependencies: [
        .package(path: "../SharedSystemLibs")
    ],
    targets: [
        .target(
            name: "CairoGraphics",
            dependencies: ["CCairo", "CPango"]
        )
    ]
)
