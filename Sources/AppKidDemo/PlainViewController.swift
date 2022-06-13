//
//  PlainViewController.swift
//  AppKidDemo
//
//  Created by Serhii Mumriak on .04.2020.
//

import Foundation
import TinyFoundation
import AppKid
import CairoGraphics
import ContentAnimation

class PlainViewController: ViewController {
    let logoImageView: View = {
        guard let image = Image(named: "fan") else {
            fatalError()
        }

        let result = ImageView(image: image)

        result.bounds = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)

        result.tag = 1
        result.masksToBounds = true

        return result
    }()

    lazy var transformTimer = Timer(timeInterval: 1.0 / 60.0, repeats: true) { [unowned logoImageView] _ in
        logoImageView.transform = logoImageView.transform.rotated(by: -.pi / 120)
    }

    deinit {
        transformTimer.invalidate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(logoImageView)

        RunLoop.current.add(transformTimer, forMode: .common)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        becomeFirstResponder()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        logoImageView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)

        let sizeLength = min(view.bounds.width * 0.6, view.bounds.height * 0.6)

        logoImageView.bounds = CGRect(x: 0.0, y: 0.0, width: sizeLength, height: sizeLength)
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override var canResignFirstResponder: Bool {
        return true
    }
}
