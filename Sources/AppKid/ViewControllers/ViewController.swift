//
//  ViewController.swift
//  AppKid
//
//  Created by Serhii Mumriak on 20.04.2020.
//

import Foundation

open class ViewController: Responder {
    // MARK: Initialization

    public override init() {
    }

    // MARK: View Loading
    open fileprivate(set) var viewIfLoaded: View? = nil
    open var view: View {
        get {
            if viewIfLoaded == nil {
                loadView()
            }

            return viewIfLoaded!
        }
        set {
            viewIfLoaded = newValue
        }
    }

    open func loadViewIfNeeded() {
        if !isViewLoaded {
            loadView()
        }
    }

    open var isViewLoaded: Bool { return viewIfLoaded != nil }

    open func loadView() {
        view = View(with: .zero)
        view.viewDelegate = self

        viewDidLoad()
    }

    open func viewDidLoad() {}

    // MARK: View Presentation

    open func viewWillAppear(_ animated: Bool) {}
    open func viewDidAppear(_ animated: Bool) {}
    open func viewWillDisappear(_ animated: Bool) {}
    open func viewDidDisappear(_ animated: Bool) {}

    open var isBeingDismissed: Bool = false
    open var isBeingPresented: Bool = false
    open var isMovingFromParent: Bool = false
    open var isMovingToParent: Bool = false

    // MARK: Appearance Transition

    internal var isAppearing: Bool? = nil
    internal var isAppearingAnimated: Bool = false

    open func beginAppearanceTransition(isAppearing: Bool, animated: Bool) {
        self.isAppearing = isAppearing
        self.isAppearingAnimated = animated

        if isAppearing {
            viewWillAppear(animated)
        } else {
            viewWillDisappear(animated)
        }
    }

    open func endAppearanceTransition() {
        guard let isAppearing = isAppearing else {
            fatalError("Unbalanced call to endAppearanceTransition")
        }

        if isAppearing {
            viewDidAppear(isAppearingAnimated)
        } else {
            viewDidDisappear(isAppearingAnimated)
        }
    }

    // MARK: View Layout

    open func viewWillLayoutSubviews() {}
    open func viewDidLayoutSubviews() {}

    // MARK: View Controller Hierarchy
    open var children: [ViewController] = []
    open fileprivate(set) weak var parent: ViewController? = nil

    open func addChild(_ childViewController: ViewController) {
        childViewController.willMove(to: self)

        removeFromParent()
        
        children.append(childViewController)
        childViewController.parent = self

        childViewController.didMove(to: self)
    }

    open func removeFromParent() {
        guard let parent = parent else { return }

        if let index = parent.children.firstIndex(of: self) {
            willMove(to: nil)

            parent.children.remove(at: index)
            self.parent = nil

            didMove(to: nil)
        }
    }

    open func willMove(to parent: ViewController?) {}
    open func didMove(to parent: ViewController?) {}

    // MARK: Responder

    override func responderWindow() -> Window? {
        return view.window
    }

    open override var nextResponder: Responder? {
        return view.superview ?? parent ?? super.nextResponder
    }
}

public extension ViewController {
    static func == (lhs: ViewController, rhs: ViewController) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}
