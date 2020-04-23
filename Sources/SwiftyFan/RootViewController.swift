//
//  RootViewController.swift
//  AppKid
//
//  Created by Serhii Mumriak on 20.04.2020.
//

import Foundation
import AppKid
import CairoGraphics

fileprivate let testString = "And if you gaze long into an abyss, the abyss also gazes into you."

class RootViewController: ViewController {
    let greenSubview: View = {
        let result = View(with: CGRect(x: 20.0, y: 20.0, width: 100.0, height: 100.0))

        result.tag = 1
        result.backgroundColor = .green
        result.transform = CairoGraphics.CGAffineTransform.identity.rotated(by: .pi / 2)
        result.masksToBounds = true

        return result
    }()

    let redSubview: View = {
        let result = View(with: CGRect(x: 20.0, y: 20.0, width: 60.0, height: 60.0))

        result.tag = 2
        result.backgroundColor = .red
        result.transform = CairoGraphics.CGAffineTransform.identity.rotated(by: .pi / 2)
        result.masksToBounds = false

        return result
    }()

    let graySubview: View = {
        let result = View(with: CGRect(x: 20.0, y: 20.0, width: 20.0, height: 20.0))

        result.tag = 3
        result.backgroundColor = .gray
        result.transform = CairoGraphics.CGAffineTransform.identity.rotated(by: .pi)

        return result
    }()

    let blueView: View = {
        let result = View(with: CGRect(x: 300.0, y: 200.0, width: 20.0, height: 80.0))
        result.tag = 4
        result.backgroundColor = .blue

        return result
    }()

    let label: Label = {
        let result = Label(with: .zero)

        result.text = testString
        result.textColor = .purple
        result.font = .systemFont(ofSize: 48.0)
        result.backgroundColor = .clear

        return result
    }()

    lazy var button: Button = {
        let result = Button(with: CGRect(x: 100.0, y: 100.0, width: 140.0, height: 44.0))

        result.backgroundColor = .clear

        result.set(title: "Spawn Window", for: .normal)

        result.set(textColor: .magenta, for: .normal)
        result.set(textColor: .magenta, for: .selected)
        result.set(textColor: .magenta, for: .highlighted)

        result.add(target: self, action: RootViewController.buttonDidTap, for: .mouseUpInside)

        return result
    }()

    lazy var transformTimer = Timer(timeInterval: 1/60.0, repeats: true) { [unowned greenSubview, unowned redSubview, unowned graySubview]  _ in
        greenSubview.transform = greenSubview.transform.rotated(by: .pi / 120)
        redSubview.transform = redSubview.transform.rotated(by: -.pi / 80)
        graySubview.transform = graySubview.transform.rotated(by: .pi / 20)
    }

    deinit {
        transformTimer.invalidate()
    }

    override init() {
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.add(subview: greenSubview)
        greenSubview.add(subview: redSubview)
        redSubview.add(subview: graySubview)
        view.add(subview: blueView)
        view.add(subview: label)
        view.add(subview: button)

        RunLoop.current.add(transformTimer, forMode: .common)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        label.frame = view.bounds
    }

    weak var draggedView: View? = nil

    override func mouseDown(with event: Event) {
        let point = view.convert(event.locationInWindow, from: view.window)
        if let hitTestView = view.hitTest(point), hitTestView != view {
            draggedView = hitTestView
        }
    }

    override func mouseDragged(with event: Event) {
        if let draggedView = draggedView {
            draggedView.center = draggedView.superview?.convert(event.locationInWindow, from: view.window) ?? draggedView.center
        }
    }

    override func mouseUp(with event: Event) {
        draggedView = nil
    }

    fileprivate func buttonDidTap(sender: Button) {
        let window = Window(contentRect: CGRect(x: 0.0, y: 0.0, width: 400.0, height: 400.0))
        window.rootViewController = RootViewController()

        Application.shared.add(window: window)
    }
}
