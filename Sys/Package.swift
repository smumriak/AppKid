// swift-tools-version: 5.8
//
//  Package.swift
//  Sys
//
//  Created by Serhii Mumriak on 29.01.2020.
//

import PackageDescription

let package = Package(
    name: "Sys",
    products: [
        .library(
            name: "LinuxSys",
            type: .static,
            targets: ["LinuxSys"]
        ),
    ],
    targets: [
        .target(name: "LinuxSys"),
    ]
)
