//
//  CalendarTimerView.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 7/4/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit
import ReactiveSwift

class CalendarTimerView: NSView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }

    let task = MutableProperty<Task?>(nil)
    let existingDuration = MutableProperty<TimeInterval>(0)

    let imageView = NSImageView()
    let label = NSTextField.label()

    let background = NSColor(calibratedWhite: 0, alpha: 0.1)
    let activeBackground = NSColor(calibratedWhite: 0, alpha: 0.15)

    let playImage = #imageLiteral(resourceName: "TimerPlayButton").tintedImageWithColor(color: NSColor.white)
    let pauseImage = #imageLiteral(resourceName: "TimePauseIcon").tintedImageWithColor(color: NSColor.white)

    override var frame: NSRect {
        didSet {
            let origin = frame.origin
            let size = frame.size

            layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            layer?.position = CGPoint(
                x: origin.x + size.width / 2,
                y: origin.y + size.height / 2
            )
        }
    }

    // MARK: - Lifecycle
    // -------------------------------------------------------------

    func setup() {
        setupViews()

        setupBinding()
    }
    

    func setupViews() {
        self.wantsLayer = true
        self.layer = CALayer()

        layer?.backgroundColor = background.cgColor
        layer?.cornerRadius = 3.0
        layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        let anim = CABasicAnimation(keyPath: "transform")
        anim.duration = 0.1
        layer?.actions = [
            "transform": anim
        ]


        imageView.image = playImage
        imageView.imageScaling = .scaleNone

        label.textColor = NSColor.white
        label.font = NSFont.systemFont(ofSize: 13).monospaced()
        label.stringValue = "0:00"

        let stack = NSStackView()
        stack.orientation = .horizontal
        stack.setViews([imageView, label], in: .leading)
        stack.spacing = 5.0

        include(stack, insets: EdgeInsets(top: 4.0, left: 6.0, bottom: 4.0, right: 6.0))
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        updateLayerToRegular()
    }

    // MARK: - Binding
    // -------------------------------------------------------

    let isRunning = MutableProperty<Bool>(false)

    func setupBinding() {
        let timer = TimerState.instance

        isRunning <~ SignalProducer.combineLatest(
            timer.runningTask.producer,
            task.producer
        ).map { runningTask, task -> Bool in
            return runningTask == task
        }

        imageView.reactive.image <~ isRunning.map { $0 ? self.pauseImage : self.playImage }

        label.reactive.stringValue <~ SignalProducer.combineLatest(
            isRunning.producer,
            timer.runningStatus.producer,
            timer.currentTime.producer,
            existingDuration.producer
            ).map { isRunning, status, date, existingDuration -> String in
                var duration = existingDuration

                if isRunning {
                    switch status {
                    case .general(since: let since):
                        duration += date.timeIntervalSince(since)
                    default: break
                    }
                }


                return Formatting.format(timeInterval: duration)
        }
    }


    // MARK: - Events
    // -------------------------------------------------------

    override func mouseDown(with event: NSEvent) {
        updateLayerToActive()
    }

    override func mouseUp(with event: NSEvent) {
        updateLayerToRegular()

        self.toggleTimer()
    }

    func updateLayerToActive() {
        layer?.backgroundColor = activeBackground.cgColor
        layer?.transform = CATransform3DMakeScale(0.92, 0.92, 1)
    }

    func updateLayerToRegular() {
        layer?.backgroundColor = background.cgColor
        layer?.transform = CATransform3DIdentity
    }

    // MARK: - Actions
    // -------------------------------------------------------

    func toggleTimer() {
        guard let task = self.task.value else { return }
        let timer = TimerState.instance

        if isRunning.value {
            timer.stop()
        } else {
            timer.restartChangingTo(task: task)
        }
    }
}


