//
//  Button.swift
//  AppKid
//
//  Created by Serhii Mumriak on 19/2/20.
//

import Foundation
import CairoGraphics

open class Button: Control {
    var stateToTitle: [Control.State: String] = [:]

    fileprivate(set) public var titleLabel: Label?

    public override init(with frame: CGRect) {
        var labelFrame = frame
        labelFrame.origin = .zero
        let titleLabel = Label(with: labelFrame)
        titleLabel.backgroundColor = .clear

        self.titleLabel = titleLabel

        super.init(with: frame)

        add(subview: titleLabel)
    }

    public func set(title: String, for state: Control.State) {
        stateToTitle[state] = title

        updateState()
    }

    internal func updateState() {
        state = {
            if isEnabled {
                if isSelected {
                    return .selected
                } else if isHighlighted{
                    return .highlighted
                } else {
                    return .normal
                }
            } else {
                return .disabled
            }
        }()

        titleLabel?.text = stateToTitle[state]
    }

    public override func render(in context: CairoGraphics.CGContext) {
        super.render(in: context)

        context.strokeColor = .black
        context.lineWidth = 2.0
        context.stroke(bounds)
    }

    open override func mouseDown(with event: Event) {
        debugPrint("Mouse down")
    }

    open override func mouseDragged(with event: Event) {
        debugPrint("Mouse dragged")
    }

    open override func mouseUp(with event: Event) {
        debugPrint("Mouseu up")
    }
}
