//
//  Button.swift
//  AppKid
//
//  Created by Serhii Mumriak on 19.02.2020.
//

import Foundation
import CairoGraphics

#if os(macOS)
    import struct CairoGraphics.CGColor
    import class CairoGraphics.CGContext
#endif

open class Button: Control {
    public enum ButtonType {
        case custom
        case system
        // case detailDisclosure
        // case infoLight
        // case infoDark
        // case contactAdd
        // case plain
        // case close
    }

    private var stateToTitle: [State: String] = [:]
    private var stateToTextColor: [State: CGColor] = [:]

    open fileprivate(set) var titleLabel: Label?

    open override var state: State {
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

        layer.borderColor = .lightGray
        layer.borderWidth = 2.0
        layer.cornerRadius = frame.size.height * 0.5
    }

    open func set(title: String?, for state: State) {
        state.deconstructed.forEach {
            if let title = title {
                stateToTitle[$0] = title
            } else {
                stateToTitle.removeValue(forKey: $0)
            }
        }

        updateText()
    }

    open func set(textColor: CGColor?, for state: State) {
        state.deconstructed.forEach {
            if let textColor = textColor {
                stateToTextColor[$0] = textColor
            } else {
                stateToTextColor.removeValue(forKey: $0)
            }
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

    open override func render(in context: CGContext) {
        super.render(in: context)

        if layer.borderWidth > 0, let borderColor = layer.borderColor {
            context.strokeColor = borderColor
            context.lineWidth = layer.borderWidth
            context.stroke(bounds)
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        var labelFrame = bounds
        labelFrame.origin = .zero
        labelFrame = labelFrame.insetBy(dx: 8.0, dy: 8.0)

        titleLabel?.frame = labelFrame
    }

    open override var bounds: CGRect {
        didSet {
            layer.cornerRadius = bounds.size.height * 0.5
        }
    }
}

public extension Button {
    static let defaultTitleColor: CGColor = .black
}
