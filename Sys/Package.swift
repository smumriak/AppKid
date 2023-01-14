// swift-tools-version: 5.7
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
        .library(name: "CLinuxSys", targets: ["CLinuxSys"]),
    ],
    targets: [
        .systemLibrary(name: "CLinuxSys"),
    ]
)
