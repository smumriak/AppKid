//
//  TextureStack.swift
//  AppKid
//
//  Created by Serhii Mumriak on 13.04.2021.
//

import Foundation
import CoreFoundation
import Volcano
import TinyFoundation

internal class TextureStack {
    fileprivate var textures: [Texture]

    init(rootTexture: Texture) {
        textures = [rootTexture]
    }

    func push(_ texture: Texture) {
        textures.append(texture)
    }

    func pop() {
        if textures.count > 1 {
            textures.removeLast()
        }
    }
}