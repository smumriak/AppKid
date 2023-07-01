// swift-tools-version: 5.8
//
//  Package.swift
//  AppKidDemo
//
//  Created by Serhii Mumriak on 29.01.2020.
//

import PackageDescription

let package = Package(
    name: "AppKid",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .executable(name: "AppKidDemo", targets: ["AppKidDemo"]),
        
        .library(.appKid, type: .dynamic),

        .library(.cCairo),
        .library(.cPango),
        .library(.cairoGraphics, type: .dynamic),
        .library("STBImage", [.stbImageRead, .stbImageWrite, .stbImageResize], type: .static),
        .library(.stbImageRead, type: .static),
        .library(.stbImageWrite, type: .static),
        .library(.stbImageResize, type: .static),

        .library(.contentAnimation, type: .dynamic),

        .library(.simpleGLM, type: .dynamic),

        .library(.cXlib),
        .library(.swiftXlib, type: .dynamic),

        // .library(.cGLib),
        // .library(.swiftyGLib, type: .dynamic),

        .library(.linuxSys),

        .library(.tinyFoundation),

        .library(.cVulkan),
        .library(.volcano, type: .dynamic),
        .library(.vulkanMemoryAllocatorAdapted, type: .static),
        .tool(.vkthings),
        .plugin(.vkThingsPlugin),
        .tool(.volcanoSL),
        .plugin(.volcanoSLPlugin),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections", .upToNextMinor(from: "1.0.0")),
        .package(url: "https://github.com/recp/cglm", branch: "master"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/CoreOffice/XMLCoder.git", from: "0.13.1"),
        .package(url: "https://github.com/apple/swift-tools-support-core", branch: "main"),
        .package(url: "https://github.com/apple/swift-atomics.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/SwiftPackageIndex/SemanticVersion.git", branch: "main"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.6"),
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
        .vkthingsLib,
        .volcanoSL,
        .volcanoSLPlugin,
        .vkThingsPlugin,
    ]
)

extension Product {
    static func library(_ target: Target, type: Library.LibraryType? = nil) -> Product {
        library(target.name, [target], type: type)
    }

    static func library(_ name: String, _ targets: [Target], type: Library.LibraryType? = nil) -> Product {
        library(name: name, type: type, targets: targets.map { $0.name })
    }

    static func tool(_ target: Target) -> Product {
        executable(name: target.name.lowercased(), targets: [target.name])
    }

    static func plugin(_ target: Target) -> Product {
        plugin(name: target.name, targets: [target.name])
    }

    static func plugin(_ name: String, _ targets: [Target]) -> Product {
        plugin(name: name, targets: targets.map { $0.name })
    }
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
    static let vkthingsLib = Target.vkthingsLib.asDependency()
    static let vkThingsPlugin = Target.vkThingsPlugin.asDependency()
    static let volcanoSL = Target.volcanoSL.asDependency()
    static let volcanoSLPlugin = Target.volcanoSLPlugin.asDependency()
}

extension Target.PluginUsage {
    static func plugin(_ target: Target) -> Target.PluginUsage {
        plugin(name: target.name)
    }
}

extension Target {
    func asDependency(condition: TargetDependencyCondition? = nil) -> Dependency {
        return .targetItem(name: name, condition: condition)
    }

    func asLibraryProduct(type: Product.Library.LibraryType? = nil) -> Product {
        .library(name: name, type: type, targets: [name])
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
        ],
        plugins: [
            .plugin(.vkThingsPlugin),
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
    static let vkthingsLib: Target = target(
        name: "VkThingsLib",
        dependencies: [
            .product(name: "XMLCoder", package: "XMLCoder"),
            .product(name: "SemanticVersion", package: "SemanticVersion"),
            .product(name: "Yams", package: "Yams"),
            .tinyFoundation,
        ],
        path: "Volcano/Sources/VkThingsLib"
    )
    static let vkthings: Target = executableTarget(
        name: "vkthings",
        dependencies: [
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            .product(name: "XMLCoder", package: "XMLCoder"),
            .tinyFoundation,
            .vkthingsLib,
        ],
        path: "Volcano/Sources/vkthings"
    )
    static let vkThingsPlugin: Target = plugin(
        name: "VkThingsPlugin",
        capability: .buildTool(),
        dependencies: [
            .vkthings,
        ],
        path: "Volcano/Plugins/VkThingsPlugin"
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
