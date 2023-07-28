// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "dockertoolchain",
    dependencies: [
        .package(url: "https://github.com/smumriak/Cuisine", branch: "main"),
        .package(url: "https://github.com/smumriak/SemanticVersion.git", branch: "main"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.6"),
    ],
    targets: [
        .executableTarget(
            name: "dockertoolchain",
            dependencies: [
                .product(name: "Cuisine", package: "Cuisine"),
                .product(name: "CuisineArgumentParser", package: "Cuisine"),
                .product(name: "SemanticVersion", package: "SemanticVersion"),
                .product(name: "Yams", package: "Yams"),
            ],
            path: "Sources"
        ),
    ]
)
