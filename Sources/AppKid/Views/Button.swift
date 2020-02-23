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
    var stateToTextColor: [Control.State: CairoGraphics.CGColor] = [:]

    fileprivate(set) public var titleLabel: Label?

    public override var state: Control.State {
        didSet {
            updateText()
        }
    }

    public override init(with frame: CGRect) {
        var labelFrame = frame
        labelFrame.origin = .zero
        labelFrame = labelFrame.insetBy(dx: 8.0, dy: 8.0)
        let titleLabel = Label(with: labelFrame)
        titleLabel.backgroundColor = .clear

        self.titleLabel = titleLabel

        super.init(with: frame)

        add(subview: titleLabel)
    }

    public func set(title: String?, for state: Control.State) {
        if let title = title {
            stateToTitle[state] = title
        } else {
            stateToTitle.removeValue(forKey: state)
        }

        updateText()
    }

    internal func updateText() {
        guard let titleLabel = titleLabel else { return }
        let state: State = {
            if isEnabled {
                if isSelected {
                    return .selected
                } else if isHighlighted {
                    return .highlighted
                } else {
                    return .normal
                }
            } else {
                return .disabled
            }
        }()

        titleLabel.text = stateToTitle[state] ?? stateToTitle[.normal]
        titleLabel.textColor = stateToTextColor[state] ?? stateToTextColor[.normal] ?? Button.defaultTitleColor
    }

    public override func render(in context: CairoGraphics.CGContext) {
        super.render(in: context)

        context.strokeColor = .black
        context.lineWidth = 2.0
        context.stroke(bounds)
    }

    open override func mouseDown(with event: Event) {
        isHighlighted = true
    }

    open override func mouseDragged(with event: Event) {
        let location = convert(event.locationInWindow, from: window)
        if point(inside: location) {
            isHighlighted = true
        } else {
            isHighlighted = false
        }
    }

    open override func mouseUp(with event: Event) {
        isHighlighted = false
    }
}

public extension Button {
    static let defaultTitleColor: CairoGraphics.CGColor = .black
}
