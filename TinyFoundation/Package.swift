// swift-tools-version:5.7
//
//  Package.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import PackageDescription

let package = Package(
    name: "TinyFoundation",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .library(name: "TinyFoundation", targets: ["TinyFoundation"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections", .upToNextMinor(from: "1.0.0")),
    ],
    targets: [
        .target(
            name: "TinyFoundation",
            dependencies: [
                .product(name: "Collections", package: "swift-collections"),
            ]
        ),
        .testTarget(
            name: "TinyFoundationTests",
            dependencies: ["TinyFoundation"]
        ),
    ]
)
