// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "vkthings",
    products: [
        .executable(name: "vkthings", targets: ["vkthings"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "1.0.0")),
        .package(url: "https://github.com/MaxDesiatov/XMLCoder.git", from: "0.13.1"),
    ],
    targets: [
        .executableTarget(
            name: "vkthings",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "XMLCoder", package: "XMLCoder"),

            ]),
        .testTarget(
            name: "vkthingsTests",
            dependencies: ["vkthings"]),
    ]
)
