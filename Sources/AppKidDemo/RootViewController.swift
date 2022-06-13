//
//  RootViewController.swift
//  AppKidDemo
//
//  Created by Serhii Mumriak on 20.04.2020.
//

import Foundation
import TinyFoundation
import AppKid
import CairoGraphics
import ContentAnimation

fileprivate let testString = "And if you gaze long into an abyss, the abyss also gazes into you."

class RootViewController: ViewController {
    let greenSubview: View = {
        let result = View(frame: CGRect(x: 20.0, y: 20.0, width: 100.0, height: 100.0))

        result.tag = 1
        result.backgroundColor = .green
        result.backgroundColor.alpha = 0.5
        result.masksToBounds = true
        result.layer.cornerRadius = 20.0
        result.layer.borderColor = .lightGray
        result.layer.borderWidth = 2.0

        return result
    }()

    let greenSubview2: View = {
        let result = View(frame: CGRect(x: 120.0, y: 20.0, width: 100.0, height: 100.0))

        result.tag = 1
        result.backgroundColor = .green
        // result.layer.cornerRadius = 20.0
        result.layer.borderColor = .lightGray
        result.layer.borderWidth = 2.0

        return result
    }()

    let redSubview: View = {
        let result = View(frame: CGRect(x: 20.0, y: 20.0, width: 60.0, height: 60.0))

        result.tag = 2
        result.backgroundColor = CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.85)
        result.masksToBounds = false
        result.layer.cornerRadius = 12.0
        result.layer.borderColor = .lightGray
        result.layer.borderWidth = 2.0

        return result
    }()

    let graySubview: View = {
        let result = View(frame: CGRect(x: 20.0, y: 20.0, width: 20.0, height: 20.0))

        result.tag = 3
        result.backgroundColor = .lightGray
        result.layer.cornerRadius = 6.0
        result.layer.borderColor = .lightGray
        result.layer.borderWidth = 2.0

        return result
    }()

    let blueSubview: View = {
        let result = View(frame: CGRect(x: 300.0, y: 200.0, width: 20.0, height: 80.0))
        result.tag = 4
        result.backgroundColor = #colorLiteral(red: 0.17254901960784313, green: 0.6274509803921569, blue: 0.9098039215686274, alpha: 1.0)
        result.layer.borderColor = .darkGray
        result.layer.borderWidth = 2.0
        result.layer.cornerRadius = 10.0

        return result
    }()

    let inputTextLabel: Label = {
        let result = Label(frame: .zero)

//        result.text = testString
        result.text = ""
        result.textColor = .purple
        result.font = .systemFont(ofSize: 48.0)
        result.backgroundColor = .clear

        return result
    }()

    lazy var spawnWindowButton: Button = {
        let result = Button(frame: CGRect(x: 0.0, y: 0.0, width: 140.0, height: 44.0))

        result.setTitle("Spawn Window", for: .normal)
        result.setTextColor(.black, for: .normal)

        result.add(target: self, action: RootViewController.spawnButtonDidTap, for: .mouseUpInside)

        return result
    }()

    lazy var spawn100WindowsButton: Button = {
        let result = Button(frame: CGRect(x: view.bounds.width - 140.0, y: 0.0, width: 140.0, height: 44.0))

        result.setTitle("Spawn 100 Windows", for: .normal)
        result.setTextColor(.black, for: .normal)
        result.titleLabel?.font = .systemFont(ofSize: 13)

        result.add(target: self, action: RootViewController.spawn100WindowsButtonDidTap, for: .mouseUpInside)

        return result
    }()

    lazy var closeCurrentWindow: Button = {
        let result = Button(frame: CGRect(x: 100.0, y: 144.0, width: 140.0, height: 44.0))

        result.setTitle("Close Current", for: .normal)
        result.setTextColor(.black, for: .normal)

        result.add(target: self, action: RootViewController.closeCurrentWindowButtonDidTap, for: .mouseUpInside)

        return result
    }()

    lazy var closeOtherWindows: Button = {
        let result = Button(frame: CGRect(x: 0.0, y: view.bounds.height - 44.0, width: 140.0, height: 44.0))

        result.setTitle("Close Other", for: .normal)
        result.setTextColor(.black, for: .normal)

        result.add(target: self, action: RootViewController.closeOtherWindowsButtonDidTap, for: .mouseUpInside)

        return result
    }()

    let scrollView: ScrollView = {
        let result = ScrollView(frame: .zero)

        result.backgroundColor = .clear

        result.contentOffset = .zero
        result.contentSize = CGSize(width: 400, height: 800)

        return result
    }()

    var lol: Int = 0

    lazy var textTimer = Timer(timeInterval: 1.0, repeats: true) { [unowned self] _ in
        spawnWindowButton.setTitle("\(lol)", for: .normal)
        lol += 1
    }

    lazy var transformTimer = Timer(timeInterval: 1.0 / 60.0, repeats: true) { [unowned greenSubview, unowned redSubview, unowned graySubview] _ in
        greenSubview.transform = greenSubview.transform.rotated(by: .pi / 120)
        redSubview.transform = redSubview.transform.rotated(by: -.pi / 80)
        graySubview.transform = graySubview.transform.rotated(by: .pi / 20)
    }

    lazy var borderWidthTimer = Timer(timeInterval: 1.0 / 60.0, repeats: true) { [unowned greenSubview] _ in
        greenSubview.layer.borderWidth += 2.0 / 60.0
    }

    let sensorLabel: Label = {
        let result = Label(frame: .zero)

        result.text = ""
        result.textColor = .purple
        result.font = .systemFont(ofSize: 48.0)
        result.backgroundColor = .clear

        return result
    }()

    lazy var sensorTimer = Timer(timeInterval: 1.0, repeats: true) { [unowned sensorLabel] _ in
        do {
            let sensorOutputPipe = Pipe()
            let sensorQuerryProcess = Process()
            sensorQuerryProcess.executableURL = URL(fileURLWithPath: "/usr/bin/nvidia-smi")
            sensorQuerryProcess.arguments = ["--query-gpu=temperature.gpu", "--format=csv,noheader", "--id=0"]
            sensorQuerryProcess.standardOutput = sensorOutputPipe

            try sensorQuerryProcess.run()
            let outputData = sensorOutputPipe.fileHandleForReading.readDataToEndOfFile()

            if let output = String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                sensorLabel.text = output + " °C"
            } else {
            }
        } catch {
            debugPrint("Sensor error: ", error)
        }
    }

    deinit {
        textTimer.invalidate()
        transformTimer.invalidate()
        // borderWidthTimer.invalidate()
        // sensorTimer.invalidate()
    }

    override init() {
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(scrollView)

        scrollView.addSubview(greenSubview)
        // scrollView.addSubview(greenSubview2)
        greenSubview.addSubview(redSubview)
        redSubview.addSubview(graySubview)
        scrollView.addSubview(blueSubview)
        scrollView.addSubview(inputTextLabel)
        scrollView.addSubview(sensorLabel)
        view.addSubview(spawnWindowButton)
        view.addSubview(spawn100WindowsButton)
        view.addSubview(closeCurrentWindow)
        view.addSubview(closeOtherWindows)

        // greenSubview.transform = greenSubview.transform.rotated(by: .pi / 20)

        RunLoop.current.add(transformTimer, forMode: .common)
        RunLoop.current.add(textTimer, forMode: .common)
        // RunLoop.current.add(borderWidthTimer, forMode: .common)
        // RunLoop.current.add(sensorTimer, forMode: .common)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        greenSubview.center.x = view.bounds.midX
        greenSubview2.center.x = greenSubview.center.x - greenSubview.bounds.width
        redSubview.center = CGPoint(x: greenSubview.bounds.midX, y: greenSubview.bounds.midY)
        graySubview.center = CGPoint(x: redSubview.bounds.midX, y: redSubview.bounds.midY)

        becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let bounds = view.bounds

        inputTextLabel.frame = bounds

        let sensorLabelHeight: CGFloat = 48.0
        sensorLabel.center = CGPoint(x: bounds.midX, y: bounds.maxY - sensorLabelHeight / 2.0)
        sensorLabel.bounds = CGRect(x: 0.0, y: 0.0, width: bounds.width, height: sensorLabelHeight)

        scrollView.center = CGPoint(x: bounds.midX, y: bounds.midY)
        scrollView.bounds.size = bounds.size
        scrollView.contentSize = CGSize(width: bounds.width, height: bounds.height * 2)

        closeOtherWindows.frame = CGRect(x: 0.0, y: bounds.height - 44.0, width: 140.0, height: 44.0)
        spawn100WindowsButton.frame = CGRect(x: bounds.width - 140.0, y: 0.0, width: 140.0, height: 44.0)
        closeCurrentWindow.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }

    weak var draggedView: View? = nil
    var draggedViewCenterDelta: CGPoint = .zero

    override func mouseDown(with event: Event) {
        let point = view.convert(event.locationInWindow, from: view.window)
        if let hitTestView = view.hitTest(point), [redSubview, greenSubview, graySubview, blueSubview].contains(hitTestView) {
            draggedView = hitTestView
            draggedViewCenterDelta = view.convert(hitTestView.center, from: hitTestView.superview) - point
        }
    }

    override func mouseDragged(with event: Event) {
        if let draggedView = draggedView, let superview = draggedView.superview {
            draggedView.center = superview.convert(event.locationInWindow, from: view.window) + draggedViewCenterDelta
        }
    }

    override func mouseUp(with event: Event) {
        draggedView = nil
        draggedViewCenterDelta = .zero
    }

    override func keyDown(with event: Event) {
        if event.characters == "q" && event.modifierFlags.contains(.command) {
            Application.shared.terminate()
        } else if event.characters == "w" && event.modifierFlags.contains(.command) {
            view.window.map {
                $0.close()
            }
        } else if event.characters == "n" && event.modifierFlags.contains(.command) {
            let window = Window(contentRect: CGRect(x: 0.0, y: 0.0, width: 400.0, height: 400.0))
            window.title = "AppKid Sample Demo"
            window.rootViewController = RootViewController()

            // Application.shared.add(window: window)
        }
        event.characters.map {
//            if event.isARepeat {
//                inputTextLabel.text = "Repeat: " + $0
//            } else {
//                inputTextLabel.text = $0
//            }
            inputTextLabel.text?.append($0)
        }
    }

    fileprivate func spawnButtonDidTap(sender: Button) {
        let window = Window(contentRect: CGRect(x: 0.0, y: 0.0, width: 400.0, height: 400.0))
        window.rootViewController = RootViewController()

        // Application.shared.add(window: window)
    }

    fileprivate func spawn100WindowsButtonDidTap(sender: Button) {
        for _ in 0..<70 {
            DispatchQueue.main.async {
                let window = Window(contentRect: CGRect(x: 0.0, y: 0.0, width: 400.0, height: 400.0))
                window.rootViewController = RootViewController()

                // Application.shared.add(window: window)
            }
        }
    }

    fileprivate func closeCurrentWindowButtonDidTap(sender: Button) {
        view.window?.close()
    }

    fileprivate func closeOtherWindowsButtonDidTap(sender: Button) {
        Application.shared.windows.forEach {
            if $0 !== view.window {
                $0.close()
            }
        }
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override var canResignFirstResponder: Bool {
        return true
    }
}
