//
//  VkLogicOp.swift
//  Volcano
//
//  Created by Serhii Mumriak on 18.01.2021.
//

import CVulkan

public extension VkLogicOp {
    static let clear: VkLogicOp = .VK_LOGIC_OP_CLEAR
    static let and: VkLogicOp = .VK_LOGIC_OP_AND
    static let andReverse: VkLogicOp = .VK_LOGIC_OP_AND_REVERSE
    static let copy: VkLogicOp = .VK_LOGIC_OP_COPY
    static let andInverted: VkLogicOp = .VK_LOGIC_OP_AND_INVERTED
    static let noOperation: VkLogicOp = .VK_LOGIC_OP_NO_OP
    static let xor: VkLogicOp = .VK_LOGIC_OP_XOR
    static let or: VkLogicOp = .VK_LOGIC_OP_OR
    static let nor: VkLogicOp = .VK_LOGIC_OP_NOR
    static let equivalent: VkLogicOp = .VK_LOGIC_OP_EQUIVALENT
    static let invert: VkLogicOp = .VK_LOGIC_OP_INVERT
    static let orReverse: VkLogicOp = .VK_LOGIC_OP_OR_REVERSE
    static let copyInverted: VkLogicOp = .VK_LOGIC_OP_COPY_INVERTED
    static let orInverted: VkLogicOp = .VK_LOGIC_OP_OR_INVERTED
    static let nand: VkLogicOp = .VK_LOGIC_OP_NAND
    static let `set`: VkLogicOp = .VK_LOGIC_OP_SET
}
