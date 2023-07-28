//
//  Login.swift
//  dockertoolchain
//
//  Created by Serhii Mumriak on 02.07.2023
//

import Cuisine

public extension Docker {
    struct Login<U: StringProtocol, P: StringProtocol, Username: InputArgument<U>, Password: InputArgument<P>>: DockerCommand {
        public let name = "login"

        let username: Username
        let password: Password

        @_transparent
        public init(_ username: U, password: P) where Username == ValueStorage<U>, Password == ValueStorage<P> {
            self.init(username: ValueStorage(username), password: ValueStorage(password))
        }

        @_transparent
        public init(_ username: U, password: Pantry.KeyPath<P>) where Username == ValueStorage<U>, Password == Pantry.KeyPath<P> {
            self.init(username: ValueStorage(username), password: password)
        }

        @_transparent
        public init(_ username: U, password: State<P>) where Username == ValueStorage<U>, Password == State<P> {
            self.init(username: ValueStorage(username), password: password)
        }

        @_transparent
        public init(_ username: Pantry.KeyPath<U>, password: P) where Username == Pantry.KeyPath<U>, Password == ValueStorage<P> {
            self.init(username: username, password: ValueStorage(password))
        }

        @_transparent
        public init(_ username: Pantry.KeyPath<U>, password: Pantry.KeyPath<P>) where Username == Pantry.KeyPath<U>, Password == Pantry.KeyPath<P> {
            self.init(username: username, password: password)
        }

        @_transparent
        public init(_ username: Pantry.KeyPath<U>, password: State<P>) where Username == Pantry.KeyPath<U>, Password == State<P> {
            self.init(username: username, password: password)
        }

        @_transparent
        public init(_ username: State<U>, password: P) where Username == State<U>, Password == ValueStorage<P> {
            self.init(username: username, password: ValueStorage(password))
        }

        @_transparent
        public init(_ username: State<U>, password: Pantry.KeyPath<P>) where Username == State<U>, Password == Pantry.KeyPath<P> {
            self.init(username: username, password: password)
        }

        @_transparent
        public init(_ username: State<U>, password: State<P>) where Username == State<U>, Password == State<P> {
            self.init(username: username, password: password)
        }
    
        @usableFromInline
        internal init(username: Username, password: Password) {
            self.username = username
            self.password = password
        }

        public func arguments(in kitchen: any Kitchen, pantry: Pantry) async throws -> [String] {
            try await [
                "--username",
                String(username.value(in: kitchen, pantry: pantry)),
                "--password",
                String(password.value(in: kitchen, pantry: pantry)),
            ]
        }
    }
}
