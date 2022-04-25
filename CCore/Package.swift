// swift-tools-version:5.5
//
//  Package.swift
//  CCore
//
//  Created by Serhii Mumriak on 15.05.2020.
//

import PackageDescription

let package = Package(
    name: "CCore",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .library(name: "CCore", targets: ["CCore"]),
    ],
    targets: [
        .target(
            name: "CCore",
            dependencies: [],
            path: "./",
            sources: [
                "empty.c",
            ],
            publicHeaderPath: "./"
        ),
    ]
)
