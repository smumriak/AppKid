// swift-tools-version:5.8
//
//  Package.swift
//  AppKidDemo
//
//  Created by Serhii Mumriak on 29.01.2020.
//

import PackageDescription

let package = Package(
    name: "AppKidDemo",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .executable(name: "AppKidDemo", targets: ["AppKidDemo"]),
        
        .appKid,

        .cCairo,
        .cPango,
        .cairoGraphics,
        .sTBImage,
        .sTBImageRead,
        .sTBImageWrite,
        .sTBImageResize,

        .contentAnimation,

        .simpleGLM,

        .cXlib,
        .swiftXlib,

        // .cGLib,
        // .swiftyGLib,

        .linuxSys,

        .tinyFoundation,

        .cVulkan,
        .volcano,
        .vulkanMemoryAllocatorAdapted,
        .vkthings,
        .volcanosl,
        .volcanoSLPlugin,
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections", .upToNextMinor(from: "1.0.0")),
        .package(url: "https://github.com/recp/cglm", branch: "master"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/CoreOffice/XMLCoder.git", from: "0.13.1"),
        .package(url: "https://github.com/apple/swift-tools-support-core", branch: "main"),
        .package(url: "https://github.com/apple/swift-atomics.git", .upToNextMajor(from: "1.0.0")),
    ],
    targets: [
        .executableTarget(
            name: "AppKidDemo",
            dependencies: [
                .appKid,
                .cairoGraphics,
                .contentAnimation,
                .tinyFoundation,
                .volcano,
            ],
            resources: [
                .copy("Resources/fan.png"),
            ]
        ),
        .testTarget(
            name: "AppKidDemoTests",
            dependencies: ["AppKidDemo"]
        ),

        .appKid,

        .cCairo,
        .cPango,
        .cairoGraphics,
        .stbImageRead,
        .stbImageWrite,
        .stbImageResize,
        .cairoGraphicsTests,

        .contentAnimation,
        .layerRenderingData,
        .contentAnimationTests,

        .simpleGLM,
        .simpleGLMTests,

        .cXlib,
        .swiftXlib,
        .swiftXlibTests,

        // .cGLib,
        // .swiftyGLib,
        // .swiftyGLibTests,
        
        .linuxSys,

        .tinyFoundation,
        .hijackingHacks,
        .tinyFoundationTests,
    
        .cVulkan,
        .cClang,
        .volcano,
        .vulkanMemoryAllocatorAdapted,
        .vkthings,
        .volcanoSL,
        .volcanoSLPlugin,
    ]
)

extension Product {
    static let appKid: Product = library(name: "AppKid", type: .dynamic, targets: [Target.appKid.name])

    static let cCairo: Product = library(name: "CCairo", targets: [Target.cCairo.name])
    static let cPango: Product = library(name: "CPango", targets: [Target.cPango.name])
    static let cairoGraphics: Product = library(name: "CairoGraphics", type: .dynamic, targets: [Target.cairoGraphics.name])
    static let sTBImage: Product = library(name: "STBImage", type: .static, targets: [Target.stbImageRead.name, Target.stbImageWrite.name, Target.stbImageResize.name])
    static let sTBImageRead: Product = library(name: "STBImageRead", type: .static, targets: [Target.stbImageRead.name])
    static let sTBImageWrite: Product = library(name: "STBImageWrite", type: .static, targets: [Target.stbImageWrite.name])
    static let sTBImageResize: Product = library(name: "STBImageResize", type: .static, targets: [Target.stbImageResize.name])

    static let contentAnimation: Product = library(name: "ContentAnimation", type: .dynamic, targets: [Target.contentAnimation.name])

    static let simpleGLM: Product = library(name: "SimpleGLM", type: .dynamic, targets: [Target.simpleGLM.name])

    static let cXlib: Product = library(name: "CXlib", targets: [Target.cXlib.name])
    static let swiftXlib: Product = library(name: "SwiftXlib", type: .dynamic, targets: [Target.swiftXlib.name])

    static let cGLib: Product = library(name: "CGLib", targets: [Target.cGLib.name])
    static let swiftyGLib: Product = library(name: "SwiftyGLib", type: .dynamic, targets: [Target.swiftyGLib.name])

    static let linuxSys: Product = library(name: "LinuxSys", targets: [Target.linuxSys.name])

    static let tinyFoundation: Product = library(name: "TinyFoundation", targets: [Target.tinyFoundation.name])

    static let cVulkan: Product = library(name: "CVulkan", targets: [Target.cVulkan.name])
    static let volcano: Product = library(name: "Volcano", type: .dynamic, targets: [Target.volcano.name])
    static let vulkanMemoryAllocatorAdapted: Product = library(name: "VulkanMemoryAllocatorAdapted", type: .static, targets: [Target.vulkanMemoryAllocatorAdapted.name])
    static let vkthings: Product = executable(name: "vkthings", targets: [Target.vkthings.name])
    static let volcanosl: Product = executable(name: "volcanosl", targets: [Target.volcanoSL.name])
    static let volcanoSLPlugin: Product = plugin(name: "VolcanoSLPlugin", targets: [Target.volcanoSLPlugin.name])
}

extension Target.Dependency {
    static let appKid = Target.appKid.asDependency()

    static let cCairo = Target.cCairo.asDependency()
    static let cPango = Target.cPango.asDependency()
    static let cairoGraphics = Target.cairoGraphics.asDependency()
    static let stbImageRead = Target.stbImageRead.asDependency()
    static let stbImageWrite = Target.stbImageWrite.asDependency()
    static let stbImageResize = Target.stbImageResize.asDependency()
    static let cairoGraphicsTests = Target.cairoGraphicsTests.asDependency()

    static let contentAnimation = Target.contentAnimation.asDependency()
    static let layerRenderingData = Target.layerRenderingData.asDependency()
    static let contentAnimationTests = Target.contentAnimationTests.asDependency()

    static let simpleGLM = Target.simpleGLM.asDependency()
    static let simpleGLMTests = Target.simpleGLMTests.asDependency()

    static let cXlib = Target.cXlib.asDependency()
    static let swiftXlib = Target.swiftXlib.asDependency()
    static let swiftXlibTests = Target.swiftXlibTests.asDependency()

    static let cGLib = Target.cGLib.asDependency()
    static let swiftyGLib = Target.swiftyGLib.asDependency()
    static let swiftyGLibTests = Target.swiftyGLibTests.asDependency()

    static let linuxSys = Target.linuxSys.asDependency()

    static let tinyFoundation = Target.tinyFoundation.asDependency()
    static let hijackingHacks = Target.hijackingHacks.asDependency()
    static let tinyFoundationTests = Target.tinyFoundationTests.asDependency()
    
    static let cVulkan = Target.cVulkan.asDependency()
    static let cClang = Target.cClang.asDependency()
    static let volcano = Target.volcano.asDependency()
    static let vulkanMemoryAllocatorAdapted = Target.vulkanMemoryAllocatorAdapted.asDependency()
    static let vkthings = Target.vkthings.asDependency()
    static let volcanoSL = Target.volcanoSL.asDependency()
    static let volcanoSLPlugin = Target.volcanoSLPlugin.asDependency()
}

extension Target {
    func asDependency(condition: PackageDescription.TargetDependencyCondition? = nil) -> Dependency {
        return .targetItem(name: name, condition: condition)
    }
}

extension Target {
    static let appKid: Target = target(
        name: "AppKid",
        dependencies: [
            .cairoGraphics,
            .contentAnimation,
            .tinyFoundation,
            .volcano,
            .simpleGLM,
            .cXlib,
            .swiftXlib,
        ],
        path: "AppKid/Sources/AppKid",
        swiftSettings: [
            .unsafeFlags(["-emit-module"]),
        ]
    )
}

extension Target {
    static let cCairo: Target = systemLibrary(
        name: "CCairo",
        path: "CairoGraphics/Sources/CCairo",
        pkgConfig: "cairo gobject-2.0",
        providers: [
            .apt(["libcairo2-dev"]),
            .brew(["cairo glib"]),
        ]
    )
    static let cPango: Target = systemLibrary(
        name: "CPango",
        path: "CairoGraphics/Sources/CPango",
        pkgConfig: "pango gobject-2.0",
        providers: [
            .apt(["libpango1.0-dev"]),
            .brew(["pango glib"]),
        ]
    )
    static let cairoGraphics: Target = target(
        name: "CairoGraphics",
        dependencies: [
            .cCairo,
            .cPango,
            .tinyFoundation,
            .simpleGLM,
            .stbImageRead,
            .stbImageWrite,
            .stbImageResize,
        ],
        path: "CairoGraphics/Sources/CairoGraphics",
        swiftSettings: [
            .unsafeFlags(["-emit-module"]),
        ]
    )
    static let stbImageRead: Target = target(
        name: "STBImageRead",
        path: "CairoGraphics/SwiftSTB/Sources/STBImageRead")

    static let stbImageWrite: Target = target(
        name: "STBImageWrite",
        path: "CairoGraphics/SwiftSTB/Sources/STBImageWrite")

    static let stbImageResize: Target = target(
        name: "STBImageResize",
        path: "CairoGraphics/SwiftSTB/Sources/STBImageResize")

    static let cairoGraphicsTests: Target = testTarget(
        name: "CairoGraphicsTests",
        dependencies: [.cairoGraphics],
        path: "CairoGraphics/Tests/CairoGraphicsTests"
    )
}

extension Target {
    static let contentAnimation: Target = target(
        name: "ContentAnimation",
        dependencies: [
            .cairoGraphics,
            .tinyFoundation,
            .volcano,
            .simpleGLM,
            .layerRenderingData,
            .product(name: "DequeModule", package: "swift-collections"),
            .product(name: "OrderedCollections", package: "swift-collections"),
        ],
        path: "ContentAnimation/Sources/ContentAnimation",
        exclude: [
            "Resources/ShaderSources",
        ],
        resources: [
            .copy("Resources/ShaderBinaries"),
        ],
        swiftSettings: [
            .unsafeFlags(["-emit-module"]),
        ],
        plugins: [
            // .plugin(name: "VolcanoSLPlugin", package: "Volcano"),
        ]
    )
    static let layerRenderingData: Target = target(
        name: "LayerRenderingData",
        dependencies: [
            .simpleGLM,
        ],
        path: "ContentAnimation/Sources/LayerRenderingData"
    )
    static let contentAnimationTests: Target = testTarget(
        name: "ContentAnimationTests",
        dependencies: [.contentAnimation],
        path: "ContentAnimation/Tests/ContentAnimationTests"
    )
}

extension Target {
    static let simpleGLM: Target = target(
        name: "SimpleGLM",
        dependencies: [
            .product(name: "cglm", package: "cglm"),
        ],
        path: "SimpleGLM/Sources/SimpleGLM",
        swiftSettings: [
            .unsafeFlags(["-emit-module"]),
        ])
    static let simpleGLMTests: Target = testTarget(
        name: "SimpleGLMTests",
        dependencies: [
            .simpleGLM,
        ],
        path: "SimpleGLM/Tests/SimpleGLMTests"
    )
}

extension Target {
    static let cXlib: Target = systemLibrary(
        name: "CXlib",
        path: "SwiftXlib/Sources/CXlib",
        pkgConfig: "x11 xext xi xcb",
        providers: [
            .apt(["libx11-dev libxext-dev libxi-dev libxcb1-dev"]),
            .brew(["xquartz"]),
        ]
    )
    static let swiftXlib: Target = target(
        name: "SwiftXlib",
        dependencies: [
            .cXlib,
            .tinyFoundation,
        ],
        path: "SwiftXlib/Sources/SwiftXlib",
        swiftSettings: [
            .unsafeFlags(["-emit-module"]),
        ]
    )
    static let swiftXlibTests: Target = testTarget(
        name: "SwiftXlibTests",
        dependencies: ["SwiftXlib"],
        path: "SwiftXlib/Tests/SwiftXlibTests"
    )
}

extension Target {
    static let cGLib: Target = systemLibrary(
        name: "CGLib",
        path: "SwiftyGLib/Sources/CGLib",
        pkgConfig: "glib-2.0",
        providers: [
            .apt(["libglib2.0-dev"]),
            .brew(["glib"]),
        ]
    )
    static let swiftyGLib: Target = target(
        name: "SwiftyGLib",
        dependencies: [
            .tinyFoundation,
            .cGLib,
        ],
        path: "SwiftyGLib/Sources/SwiftyGLib",
        swiftSettings: [
            .unsafeFlags(["-emit-module"]),
        ])
    static let swiftyGLibTests: Target = testTarget(
        name: "SwiftyGLibTests",
        dependencies: [.swiftyGLib],
        path: "SwiftyGLib/Tests/SwiftyGLibTests"
    )
}

extension Target {
    static let linuxSys: Target = systemLibrary(
        name: "LinuxSys",
        path: "Sys/Sources/LinuxSys"
    )
}

extension Target {
    static let tinyFoundation: Target = target(
        name: "TinyFoundation",
        dependencies: [
            .product(name: "DequeModule", package: "swift-collections"),
            .product(name: "Atomics", package: "swift-atomics"),
            .linuxSys,
            .hijackingHacks,
        ],
        path: "TinyFoundation/Sources/TinyFoundation"
    )
    static let hijackingHacks: Target = target(
        name: "HijackingHacks",
        path: "TinyFoundation/Sources/HijackingHacks",
        cSettings: [
            .unsafeFlags([
                "-I/opt/swift/usr/lib/swift",
            ]),
        ]
    )
    static let tinyFoundationTests: Target = testTarget(
        name: "TinyFoundationTests",
        dependencies: [.tinyFoundation],
        path: "TinyFoundation/Tests/TinyFoundationTests"
    )
}

extension Target {
    static let cVulkan: Target = systemLibrary(
        name: "CVulkan",
        path: "Volcano/Sources/CVulkan",
        pkgConfig: "vulkan",
        providers: [
            .apt(["vulkan-sdk libwayland-dev libx11-dev"]),
        ]
    )
    static let cClang: Target = systemLibrary(
        name: "CClang",
        path: "Volcano/Sources/CClang",
        pkgConfig: "clang",
        providers: [
            .apt(["libclang-12-dev"]),
        ]
    )
    static let volcano: Target = target(
        name: "Volcano",
        dependencies: [
            .product(name: "Atomics", package: "swift-atomics"),
            .cVulkan,
            .cXlib,
            .tinyFoundation,
            .simpleGLM,
            .vulkanMemoryAllocatorAdapted,
        ],
        path: "Volcano/Sources/Volcano",
        swiftSettings: [
            .unsafeFlags(["-emit-module"]),
            .define("VOLCANO_PLATFORM_LINUX", .when(platforms: [.linux])),
            .define("VOLCANO_PLATFORM_MACOS", .when(platforms: [.macOS])),
            .define("VOLCANO_PLATFORM_IOS", .when(platforms: [.iOS])),
            .define("VOLCANO_PLATFORM_APPLE_METAL", .when(platforms: [.iOS, .macOS])),
            .define("VOLCANO_PLATFORM_WINDOWS", .when(platforms: [.windows])),
            .define("VOLCANO_PLATFORM_ANDROID", .when(platforms: [.android])),
        ]
    )
    static let vulkanMemoryAllocatorAdapted: Target = target(
        name: "VulkanMemoryAllocatorAdapted",
        dependencies: [
            .cVulkan,
        ],
        path: "Volcano/Sources/VulkanMemoryAllocatorAdapted",
        cSettings: [
            .unsafeFlags(["-Wno-nullability-completeness"]),
        ],
        cxxSettings: [
            .unsafeFlags(["-Wno-nullability-completeness", "-std=c++17"]),
        ]
    )
    static let vkthings: Target = executableTarget(
        name: "vkthings",
        dependencies: [
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            .product(name: "XMLCoder", package: "XMLCoder"),
            .tinyFoundation,
        ],
        path: "Volcano/Sources/vkthings"
    )
    static let volcanoSL: Target = executableTarget(
        name: "VolcanoSL",
        dependencies: [
            .cClang,
            .tinyFoundation,
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            .product(name: "TSCBasic", package: "swift-tools-support-core"),
        ],
        path: "Volcano/Sources/VolcanoSL",
        resources: [
            .copy("Resources/GLSLTypesInclude.h"),
        ]
    )
    static let volcanoSLPlugin: Target = plugin(
        name: "VolcanoSLPlugin",
        capability: .buildTool(),
        dependencies: [.volcanoSL],
        path: "Volcano/Plugins/VolcanoSLPlugin"
    )
}
