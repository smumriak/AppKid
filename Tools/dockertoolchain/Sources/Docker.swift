//
//  Docker.swift
//  dockertoolchain
//
//  Created by Serhii Mumriak on 02.07.2023
//

import Cuisine

public protocol StringListRepresentable {
    var stringList: [String] { get }
}

public extension StringListRepresentable {
    var stringList: [String] { [] }
}

public protocol DockerCommand: StringListRepresentable, BlockingRecipe {
    var name: String { get }

    func arguments(in kitchen: Kitchen, pantry: Pantry) async throws -> [String]
}

public extension DockerCommand {
    func perform(in kitchen: Kitchen, pantry: Pantry) async throws {
    }
}

public enum Docker {}

// PipeBuilder

public protocol PipedInputRecipe<Input>: Recipe {
    associatedtype Input

    func consumeInput(_ input: Input) async throws
}

public protocol PipedOutputRecipe<Output>: Recipe {
    associatedtype Output

    func perform(in kitchen: any Kitchen, pantry: Pantry) async throws -> Output
}

public extension PipedOutputRecipe {
    func perform(in kitchen: any Kitchen, pantry: Pantry) async throws {
        _ = try await perform(in: kitchen, pantry: pantry)
    }
}

public struct Pipe<Source: PipedOutputRecipe, Sink: PipedInputRecipe>: BlockingRecipe {
    let source: Source
    let sink: Sink

    public func perform(in kitchen: Cuisine.Kitchen, pantry: Cuisine.Pantry) async throws {
        if let outputPipe = self as PipedOutputRecipe<Source.Output> {
        }
    }
}

extension Pipe: PipedInputRecipe where Source: PipedInputRecipe {
    public typealias Input = Source.Input
    public func consumeInput(_ input: Input) async throws {
        try await source.consumeInput(input)
    }
}

extension Pipe: PipedOutputRecipe where Sink: PipedOutputRecipe {
    public func perform(in kitchen: any Kitchen, pantry: Pantry) async throws -> Output {
    }
}
