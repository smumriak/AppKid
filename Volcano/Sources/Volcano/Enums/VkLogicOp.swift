//
//  VkLogicOp.swift
//  Volcano
//
//  Created by Serhii Mumriak on 18.01.2021.
//

import CVulkan

public extension VkLogicOp {
    static let clear: Self = .VK_LOGIC_OP_CLEAR
    static let and: Self = .VK_LOGIC_OP_AND
    static let andReverse: Self = .VK_LOGIC_OP_AND_REVERSE
    static let copy: Self = .VK_LOGIC_OP_COPY
    static let andInverted: Self = .VK_LOGIC_OP_AND_INVERTED
    static let noOperation: Self = .VK_LOGIC_OP_NO_OP
    static let xor: Self = .VK_LOGIC_OP_XOR
    static let or: Self = .VK_LOGIC_OP_OR
    static let nor: Self = .VK_LOGIC_OP_NOR
    static let equivalent: Self = .VK_LOGIC_OP_EQUIVALENT
    static let invert: Self = .VK_LOGIC_OP_INVERT
    static let orReverse: Self = .VK_LOGIC_OP_OR_REVERSE
    static let copyInverted: Self = .VK_LOGIC_OP_COPY_INVERTED
    static let orInverted: Self = .VK_LOGIC_OP_OR_INVERTED
    static let nand: Self = .VK_LOGIC_OP_NAND
    static let set: Self = .VK_LOGIC_OP_SET
}
