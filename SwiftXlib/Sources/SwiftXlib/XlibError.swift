//
//  XlibError.swift
//  SwiftXlib
//
//  Created by Serhii Mumriak on 21.12.2020.
//

import Foundation

import CXlib

public enum XlibExtension: String {
    case sync = "XSync"
    case input2 = "XInput2"
}

public enum XlibError: Error {
    case failedToOpenDisplay
    case badResult(XlibResult)
    case missingExtension(XlibExtension)
}

extension XlibResult: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .badAccess: return "Bad Access"
        case .badAlloc: return "Bad Alloc"
        case .badAtom: return "Bad Atom"
        case .badColor: return "Bad Color"
        case .badCursor: return "Bad Cursor"
        case .badDrawable: return "Bad Drawable"
        case .badFont: return "Bad Font"
        case .badGC: return "bad Graphics Context"
        case .badIDChoice: return "Bad ID Choice"
        case .badImplementation: return "Bad Implementation"
        case .badLength: return "Bad Length"
        case .badMatch: return "Bad Match"
        case .badName: return "Bad Name"
        case .badPixmap: return "Bad Pixmap"
        case .badRequest: return "Bad Request"
        case .badValue: return "Bad Value"
        case .badWindow: return "Bad Window"
        default: return "Unknown"
        }
    }
}
