//
//  ScrollView.swift
//  AppKid
//
//  Created by Serhii Mumriak on 27.04.2020.
//

import Foundation
import CairoGraphics

open class ScrollView: View {
    open weak var delegate: ScrollViewDelegate? = nil

    open var contentSize: CGSize = .zero {
        didSet {
            invalidateTransforms()
            setNeedsLayout()
            setNeedsDisplay()
        }
    }

    open var contentOffset: CGPoint {
        get {
            return bounds.origin
        }
        set {
            bounds.origin = newValue
        }
    }

    open override func scrollWheel(with event: Event) {
        var newContentOffset = contentOffset

        if contentSize.width > bounds.width {
            newContentOffset.x += event.scrollingDeltaX * 35

            if newContentOffset.x < 0 { newContentOffset.x = 0 }

            if newContentOffset.x + bounds.width > contentSize.width {
                newContentOffset.x = contentSize.width - bounds.width
            }
        }

        if contentSize.height > bounds.height {
            newContentOffset.y += event.scrollingDeltaY * 35

            if newContentOffset.y < 0 { newContentOffset.y = 0 }

            if newContentOffset.y + bounds.height > contentSize.height {
                newContentOffset.y = contentSize.height - bounds.height
            }
        }

        contentOffset = newContentOffset
    }
}

public protocol ScrollViewDelegate: AnyObject {
    func scrollViewDidScroll(_ scrollView: ScrollView)
    func scrollViewShouldScrollToTop(_ scrollView: ScrollView) -> Bool
    func scrollViewDidScrollToTop(_ scrollView: ScrollView)
}

public extension ScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: ScrollView) {}
    func scrollViewShouldScrollToTop(_ scrollView: ScrollView) -> Bool { return true }
    func scrollViewDidScrollToTop(_ scrollView: ScrollView) {}
}
