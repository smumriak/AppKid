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

        result.set(title: "Normal", for: .normal)
        result.set(title: "Selected", for: .selected)
        result.set(title: "Highlighted", for: .highlighted)

        result.set(textColor: .magenta, for: .normal)
        result.set(textColor: .magenta, for: .selected)
        result.set(textColor: .magenta, for: .highlighted)

        return result
    }()

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

        let transformTimer = Timer(timeInterval: 1/60.0, repeats: true) { [weak greenSubview, weak redSubview, weak graySubview]  _ in
            greenSubview?.transform = greenSubview?.transform.rotated(by: .pi / 120) ?? .identity
            redSubview?.transform = redSubview?.transform.rotated(by: -.pi / 80) ?? .identity
            graySubview?.transform = graySubview?.transform.rotated(by: .pi / 20) ?? .identity
        }

        RunLoop.current.add(transformTimer, forMode: .common)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        label.frame = view.bounds
    }
}
