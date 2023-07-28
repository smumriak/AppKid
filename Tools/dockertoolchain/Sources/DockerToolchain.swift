//
//  DockerToolchain.swift
//  dockertoolchain
//
//  Created by Serhii Mumriak on 01.07.2023
//

import Cuisine
import CuisineArgumentParser
import ArgumentParser
import Yams
import RegexBuilder

@main
struct DockerToolchain: CuisineParsableCommand {
    var pantry: Pantry = Pantry()
        
    var body: some Recipe {
        Action { kitchen, pantry in
            let metadataURL = kitchen.currentDirectory.appendingPathComponent(".appkid.yml", isDirectory: false)
            let metadataString = try String(contentsOf: metadataURL, encoding: .utf8)
            let decoder = YAMLDecoder()
            pantry.appKidMetadata = try decoder.decode(from: metadataString)
        }

        ChDir("Docker") {
            ForEach(\.appKidMetadata.swiftVersions, mode: .concurrent) { version in
                Docker.Tag("hello", "pepega")
                // let _ = debugPrint("\(version)")
                // Group {
                //     Run("docker") {
                //         "build"
                //         "-f "
                //         "Dockerfile.appkid_toolchain"
                //         "--no-cache"
                //         "--build-arg"
                //         "swift_version=\(version)"
                //         "."
                //     }
                //     Run("docker")
                // }
            }
        }
    }
}

// struct LoadMetadataRecipe: BlockingRecipe {

// }

public protocol ActionRecipeProtocol {
    typealias BlockType = (_ kitchen: Cuisine.Kitchen, _ pantry: Cuisine.Pantry) async throws -> ()

    var block: BlockType { get }
}

public extension ActionRecipeProtocol where Self: Recipe {
    func perform(in kitchen: Cuisine.Kitchen, pantry: Cuisine.Pantry) async throws {
        try await block(kitchen, pantry)
    }
}

public struct Action: ActionRecipeProtocol, BlockingRecipe {
    public let block: BlockType

    @Pantry.Item(\.appKidMetadata)
    var pepega: AppKidMetadata

    public init(_ block: @escaping BlockType) {
        self.block = block
    }

    public func perform(in kitchen: Cuisine.Kitchen, pantry: Cuisine.Pantry) async throws {
        debugPrint(pepega)
        try await block(kitchen, pantry)
    }
}

public struct AsyncAction: ActionRecipeProtocol, NonBlockingRecipe {
    public let block: BlockType

    public init(_ block: @escaping BlockType) {
        self.block = block
    }
}
