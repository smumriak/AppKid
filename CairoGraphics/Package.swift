// swift-tools-version:5.1
//
//  Package.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 11.05.2020.
//

import PackageDescription

let package = Package(
    name: "CairoGraphics",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "CairoGraphics", type: .dynamic, targets: ["CairoGraphics"])
    ],
    dependencies: [
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .systemLibrary(
            name: "CCairo",
            pkgConfig: "cairo",
            providers: [
                .apt(["libcairo2-dev"]),
                .brew(["cairo"])
            ]
        ),
        .systemLibrary(
            name: "CPango",
            pkgConfig: "pango",
            providers: [
                .apt(["libpango1.0-dev"]),
                .brew(["pango glib"])
            ]
        ),
        .target(
            name: "CairoGraphics",
            dependencies: ["CCairo", "CPango"]
        )
    ]
)
