// swift-tools-version:5.3
//
//  Package.swift
//  SimpleGLM
//
//  Created by Serhii Mumriak on 13.09.2020.
//

import PackageDescription

let package = Package(
    name: "SimpleGLM",
    products: [
        .library(name: "SimpleGLM", targets: ["SimpleGLM"]),
    ],
    dependencies: [
        .package(name: "cglm", url: "https://github.com/smumryak/cglm", .branch("master")),
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
