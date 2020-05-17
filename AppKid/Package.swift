// swift-tools-version:5.1
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
                "CX11",
                "CXInput2",
                "CEpoll",
                "CairoGraphics",
                "ContentAnimation",
                "TinyFoundation"
            ]
        )
    ]
)
