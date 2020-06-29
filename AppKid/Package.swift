// swift-tools-version:5.3
//
//  Package.swift
//  AppKid
//
//  Created by Serhii Mumriak on 11.05.2020.
//

import PackageDescription

let package = Package(
    name: "AppKid",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "AppKid", type: .dynamic, targets: ["AppKid"])
    ],
    dependencies: [
        .package(path: "../SharedSystemLibs"),
        .package(path: "../TinyFoundation"),
        .package(path: "../CairoGraphics"),
    	.package(path: "../ContentAnimation")
    ],
    targets: [
        .target(
            name: "AppKid",
            dependencies: [
                .product(name: "CX11", package: "SharedSystemLibs"),
                .product(name: "CXInput2", package: "SharedSystemLibs"),
                .product(name: "CEpoll", package: "SharedSystemLibs"),
                .product(name: "CairoGraphics", package: "CairoGraphics"),
                .product(name: "ContentAnimation", package: "ContentAnimation"),
                .product(name: "TinyFoundation", package: "TinyFoundation")
            ]
        )
    ]
)
