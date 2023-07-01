//
//  VolcanoSLPlugin.swift
//  VolcanoSL
//
//  Created by Serhii Mumriak on 16.06.2021.
//

import PackagePlugin
import Foundation

@main
struct VolcanoSLPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        guard let target = target as? SourceModuleTarget else {
            return []
        }

        let headersSearchPaths = target.dependencies
            .compactMap { dependency -> ClangSourceModuleTarget? in
                switch dependency {
                    case .target(let dependencyTarget): return dependencyTarget as? ClangSourceModuleTarget
                    default: return nil
                }
            }
            .compactMap {
                $0.publicHeadersDirectory?.string
            }
            .flatMap {
                ["-I", $0]
            }
            
        let glslOutputPath = context.pluginWorkDirectory.appending("glsl")
        let spvOutputPath = context.pluginWorkDirectory.appending("spv")

        let fileManager = FileManager.default

        try fileManager.createDirectory(atPath: glslOutputPath.string, withIntermediateDirectories: true)
        try fileManager.createDirectory(atPath: spvOutputPath.string, withIntermediateDirectories: true)

        let volcanoslPath = try context.tool(named: "volcanosl").path

        return target.sourceFiles
            .filter {
                return $0.path.extension == "volcano"
            }
            .map { file in
                let inputFilePath = file.path
                let glslOutputFilename = inputFilePath.lastComponent + ".glsl"
                let spvOutputFilename = inputFilePath.stem + ".spv"
                
                let glslOutputFilePath = glslOutputPath.appending(glslOutputFilename)
                let spvOutputFilePath = spvOutputPath.appending(spvOutputFilename)

                let volcanoslArguments: [String] = [inputFilePath.string, "-g", glslOutputFilePath.string, "-s", spvOutputFilePath.string] + headersSearchPaths

                let volcanoSLCommand: Command = .buildCommand(
                    displayName: "VolcanoSL: processing \(inputFilePath.lastComponent)",
                    executable: volcanoslPath,
                    arguments: volcanoslArguments,
                    inputFiles: [inputFilePath],
                    outputFiles: [spvOutputFilePath]
                )

                return volcanoSLCommand
            }
    }
}
