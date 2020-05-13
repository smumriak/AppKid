// swift-tools-version:5.1
//
//  Package.swift
//  SwiftyFan
//
//  Created by Serhii Mumriak on 29.01.2020.
//

import PackageDescription

let package = Package(
    name: "SwiftyFan",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(name: "SwiftyFan", targets: ["SwiftyFan"])
    ],
    dependencies: [
        .package(path: "./AppKid"),
        .package(path: "./CairoGraphics")
    ],
    targets: [
        .target(
            name: "SwiftyFan",
            dependencies: ["AppKid", "CairoGraphics"]
        ),
        .testTarget(
            name: "SwiftyFanTests",
            dependencies: ["SwiftyFan"]
        )
    ]
)
