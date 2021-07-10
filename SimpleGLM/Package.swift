// swift-tools-version:5.5
//
//  Package.swift
//  SimpleGLM
//
//  Created by Serhii Mumriak on 13.09.2020.
//

import PackageDescription

let package = Package(
    name: "SimpleGLM",
    platforms: [
        .macOS(.v11),
    ],
    products: [
        .library(name: "SimpleGLM", targets: ["SimpleGLM"]),
    ],
    dependencies: [
        .package(name: "cglm", url: "https://github.com/recp/cglm", .branch("master")),
    ],
    targets: [
        .target(
            name: "SimpleGLM",
            dependencies: [
                .product(name: "cglm", package: "cglm"),
            ]),
        .testTarget(
            name: "SimpleGLMTests",
            dependencies: [
                "SimpleGLM",
            ]),
    ]
)
