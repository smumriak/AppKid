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
        .library(name: "CCairo", targets: ["CCairo"]),
        .library(name: "CPango", targets: ["CPango"]),
        .library(name: "CVulkan", targets: ["CVulkan"]),
    ],
    targets: [
        .target(
            name: "CCore",
            dependencies: [],
            path: "CCore"
        ),
        .systemLibrary(
            name: "CCairo",
            path: "CCairo",
            pkgConfig: "cairo gobject-2.0",
            providers: [
                .apt(["libcairo2-dev"]),
                .brew(["cairo glib"]),
            ]
        ),
        .systemLibrary(
            name: "CPango",
            path: "CPango",
            pkgConfig: "pango gobject-2.0",
            providers: [
                .apt(["libpango1.0-dev"]),
                .brew(["pango glib"]),
            ]
        ),
        .systemLibrary(
            name: "CVulkan",
            path: "CVulkan",
            pkgConfig: "vulkan"
        ),
    ]
)
