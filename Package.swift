// swift-tools-version:5.1
//
//  Package.swift
//  SwiftyFan
//
//  Created by Serhii Mumriak on 29.01.2020.
//

import PackageDescription

let package = Package(
    name: "SwiftyFan",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .systemLibrary(
            name: "CX11",
            pkgConfig: "x11",
            providers: [
                .apt(["libx11-dev"]),
                .brew(["xquartz"])
            ]
        ),
        .systemLibrary(
            name: "CXInput2",
            pkgConfig: "xi",
            providers: [
                .apt(["libxi-dev"]),
                .brew(["xquartz"])
            ]
        ),
        .systemLibrary(name: "CEpoll"),
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
                .apt(["libpango1.0-dev libglib2.0-dev"]),
                .brew(["pango glib"])
            ]
        ),
        .target(
            name: "SwiftyFan",
            dependencies: ["AppKid"]
        ),
        .target(
            name: "AppKid",
            dependencies: ["CX11", "CXInput2", "CEpoll", "CairoGraphics"]
        ),
        .target(
            name: "CairoGraphics",
            dependencies: ["CCairo", "CPango"]
        ),
        .testTarget(
            name: "SwiftyFanTests",
            dependencies: ["SwiftyFan"]
        ),
    ]
)
