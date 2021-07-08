// swift-tools-version:5.5
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
        .macOS(.v11),
    ],
    products: [
        .library(name: "TinyFoundation", type: .dynamic, targets: ["TinyFoundation"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections", .upToNextMinor(from: "0.0.0")),
    ],
    targets: [
        .target(name: "TinyFoundation",
                dependencies: [
                    .product(name: "Collections", package: "swift-collections"),
                ]
        ),
    ]
)
