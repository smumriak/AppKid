// swift-tools-version:5.5
//
//  Package.swift
//  SharedSystemLibs
//
//  Created by Serhii Mumriak on 15.05.2020.
//

import PackageDescription

let package = Package(
    name: "SharedSystemLibs",
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
            path: "CCore"
        ),
    ]
)
