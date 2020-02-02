// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "SwiftyFan",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .systemLibrary(name: "CX11", pkgConfig: "x11", providers: [.apt(["libx11-dev"])]),
        .systemLibrary(name: "CEpoll"),
        .target(name: "SwiftyFan", dependencies: ["AppKid"]),
        .target(name: "AppKid", dependencies: ["CX11", "CEpoll"]),
        .testTarget(name: "SwiftyFanTests", dependencies: ["SwiftyFan"]),
    ]
)
