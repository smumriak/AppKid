// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "vulkancodegen",
    dependencies: [
        .package(url: "https://github.com/smumriak/Cuisine", branch: "main"),
        .package(url: "https://github.com/smumriak/SemanticVersion.git", branch: "main"),
    ],

    targets: [
        .executableTarget(
            name: "vulkancodegen",
            dependencies: [
                .product(name: "Cuisine", package: "Cuisine"),
                .product(name: "CuisineArgumentParser", package: "Cuisine"),
                .product(name: "SemanticVersion", package: "SemanticVersion"),
            ]
        ),
    ]
)
