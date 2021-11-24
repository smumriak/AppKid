// swift-tools-version: 5.5
//
//  Package.swift
//  SwiftyGLib
//
//  Created by Serhii Mumriak on 20.11.2021.
//

import PackageDescription

let package = Package(
    name: "SwiftyGLib",
    products: [
        .library(name: "SwiftyGLib", type: .dynamic, targets: ["SwiftyGLib"]),
    ],
    dependencies: [
        .package(path: "../SharedSystemLibs"),
        .package(path: "../TinyFoundation"),
    ],
    targets: [
        .target(
            name: "SwiftyGLib",
            dependencies: [
                .product(name: "TinyFoundation", package: "TinyFoundation"),
                "CGLib",
            ],
            swiftSettings: [
                .unsafeFlags(["-emit-module"]),
            ]),
        .testTarget(
            name: "SwiftyGLibTests",
            dependencies: ["SwiftyGLib"]),
        .systemLibrary(
            name: "CGLib",
            pkgConfig: "glib-2.0",
            providers: [
                .apt(["libglib2.0-dev"]),
                .brew(["glib"]),
            ]
        ),
    ]
)
 