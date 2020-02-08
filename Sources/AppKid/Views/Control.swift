//
//  Control.swift
//  AppKid
//
//  Created by Serhii Mumriak on 7/2/20.
//

import Foundation

public class Control: View {
    var isEnabled = true
    
    public typealias Action = (_ sender: Control) -> ()
    fileprivate var targetWrappers = [ControlInvokable]()

    public func set<TargetType: AnyObject>(target: TargetType?, action: @escaping (TargetType) -> Action) {
        if let target = target {
            let targetWrapper = TargetWrapper(target: target, action: action)
            targetWrappers.append(targetWrapper)
        }
    }
}

fileprivate protocol ControlInvokable {
    func invoke(sender: Control)
}

fileprivate final class TargetWrapper<TargetType: AnyObject> : ControlInvokable {
    weak var target: TargetType?
    let action: (TargetType) -> Control.Action
    
    init(target: TargetType, action: @escaping (TargetType) -> Control.Action) {
        self.target = target
        self.action = action
    }
    
    func invoke(sender: Control) {
        if let target = target {
            action(target)(sender)
        }
    }
}
