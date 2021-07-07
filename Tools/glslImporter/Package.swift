// swift-tools-version:5.5
//
//  Package.swift
//  glslImporter
//
//  Created by Serhii Mumriak on 13.06.2021.
//

import PackageDescription

let package = Package(
    name: "glslImporter",
    platforms: [
        .macOS(.v11),
    ],
    products: [
        .executable(name: "glslImporter", targets: ["glslImporter"]),
        // .plugin(name: "GLSLImporterPlugin", targets: ["GLSLImporterPlugin"])
    ],
    dependencies: [
        .package(path: "../../TinyFoundation"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.4.0"),
    ],
    targets: [
        .executableTarget(
            name: "glslImporter",
            dependencies: [
                "CClang",
                .product(name: "TinyFoundation", package: "TinyFoundation"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            resources: [
                .copy("Resources/GLSLTypesInclude.h"),
            ]),
        // .plugin(
        //     name: "GLSLImporterPlugin",
        //     capability: .buildTool(),
        //     dependencies: [.target(name: "glslImporter")]
        // ),
        .systemLibrary(
            name: "CClang",
            pkgConfig: "clang",
            providers: [
                .apt(["libclang-dev"]),
            ]
        ),
        .testTarget(
            name: "glslImporterTests",
            dependencies: ["glslImporter"]),
    ]
)
