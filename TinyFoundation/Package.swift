// swift-tools-version:5.3
//
//  Package.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import PackageDescription

let package = Package(
    name: "TinyFoundation",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "TinyFoundation", type: .dynamic, targets: ["TinyFoundation"])
    ],
    targets: [
        .target(name: "TinyFoundation")
    ]
)
