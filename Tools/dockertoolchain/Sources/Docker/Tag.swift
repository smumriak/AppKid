//
//  Tag.swift
//  dockertoolchain
//
//  Created by Serhii Mumriak on 02.07.2023
//

import Cuisine

public extension Docker {
    struct Tag<S, Source, T, Target>: DockerCommand where S: StringProtocol, T: StringProtocol, Source: InputArgument<S>, Target: InputArgument<T> {
        public let name = "tag"
        let source: Source
        let target: Target

        @_transparent
        public init(_ source: S, _ target: T) where Source == ValueStorage<S>, Target == ValueStorage<T> {
            self.init(source: ValueStorage(source), target: ValueStorage(target))
        }

        @_transparent
        public init(_ source: S, _ target: Pantry.KeyPath<T>) where Source == ValueStorage<S>, Target == Pantry.KeyPath<T> {
            self.init(source: ValueStorage(source), target: target)
        }

        @_transparent
        public init(_ source: S, _ target: State<T>) where Source == ValueStorage<S>, Target == State<T> {
            self.init(source: ValueStorage(source), target: target)
        }

        @_transparent
        public init(_ source: Pantry.KeyPath<S>, _ target: T) where Source == Pantry.KeyPath<S>, Target == ValueStorage<T> {
            self.init(source: source, target: ValueStorage(target))
        }

        @_transparent
        public init(_ source: Pantry.KeyPath<S>, _ target: Pantry.KeyPath<T>) where Source == Pantry.KeyPath<S>, Target == Pantry.KeyPath<T> {
            self.init(source: source, target: target)
        }

        @_transparent
        public init(_ source: Pantry.KeyPath<S>, _ target: State<T>) where Source == Pantry.KeyPath<S>, Target == State<T> {
            self.init(source: source, target: target)
        }

        @_transparent
        public init(_ source: State<S>, _ target: T) where Source == State<S>, Target == ValueStorage<T> {
            self.init(source: source, target: ValueStorage(target))
        }

        @_transparent
        public init(_ source: State<S>, _ target: Pantry.KeyPath<T>) where Source == State<S>, Target == Pantry.KeyPath<T> {
            self.init(source: source, target: target)
        }

        @_transparent
        public init(_ source: State<S>, _ target: State<T>) where Source == State<S>, Target == State<T> {
            self.init(source: source, target: target)
        }
    
        @usableFromInline
        internal init(source: Source, target: Target) {
            self.source = source
            self.target = target
        }

        public func arguments(in kitchen: any Kitchen, pantry: Pantry) async throws -> [String] {
            try await [
                String(source.value(in: kitchen, pantry: pantry)),
                String(target.value(in: kitchen, pantry: pantry)),
            ]
        }
    }
}
