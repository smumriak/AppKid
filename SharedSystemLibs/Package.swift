// swift-tools-version:5.3
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
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "CX11", targets: ["CX11"]),
        .library(name: "CXInput2", targets: ["CXInput2"]),
        .library(name: "CCairo", targets: ["CCairo"]),
        .library(name: "CPango", targets: ["CPango"]),
        .library(name: "CVulkan", targets: ["CVulkan"]),
    ],
    targets: [
        .systemLibrary(
            name: "CX11",
            path: "CX11",
            pkgConfig: "x11",
            providers: [
                .apt(["libx11-dev"]),
                .brew(["xquartz"]),
            ]
        ),
        .systemLibrary(
            name: "CXInput2",
            path: "CXInput2",
            pkgConfig: "xi",
            providers: [
                .apt(["libxi-dev"]),
                .brew(["xquartz"]),
            ]
        ),
        .systemLibrary(
            name: "CCairo",
            path: "CCairo",
            pkgConfig: "cairo",
            providers: [
                .apt(["libcairo2-dev"]),
                .brew(["cairo"]),
            ]
        ),
        .systemLibrary(
            name: "CPango",
            path: "CPango",
            pkgConfig: "pango",
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
