// swift-tools-version:5.5
//
//  Package.swift
//  AppKidDemo
//
//  Created by Serhii Mumriak on 29.01.2020.
//

import PackageDescription

let package = Package(
    name: "AppKidDemo",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .executable(name: "AppKidDemo", targets: ["AppKidDemo"]),
    ],
    dependencies: [
        .package(path: "./TinyFoundation"),
        .package(path: "./AppKid"),
        .package(path: "./CairoGraphics"),
        .package(path: "./ContentAnimation"),
        .package(path: "./Volcano"),
    ],
    targets: [
        .executableTarget(
            name: "AppKidDemo",
            dependencies: [
                .product(name: "AppKid", package: "AppKid"),
                .product(name: "CairoGraphics", package: "CairoGraphics"),
                .product(name: "ContentAnimation", package: "ContentAnimation"),
                .product(name: "TinyFoundation", package: "TinyFoundation"),
                .product(name: "Volcano", package: "Volcano"),
            ],
            resources: [
                .copy("Resources/AppIcon.png"),
                .copy("Resources/fan.png"),
            ]
        ),
        .testTarget(
            name: "AppKidDemoTests",
            dependencies: ["AppKidDemo"]
        ),
    ]
)
