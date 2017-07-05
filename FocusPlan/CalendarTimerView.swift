//
//  CalendarTimerView.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 7/4/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit

class CalendarTimerView: NSView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }

    let imageView = NSImageView()
    let label = NSTextField.label()

    let background = NSColor(calibratedWhite: 0, alpha: 0.1)
    let activeBackground = NSColor(calibratedWhite: 0, alpha: 0.15)

    func setup() {
        setupViews()
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


        let image = #imageLiteral(resourceName: "TimerPlayButton")
        imageView.image = image.tintedImageWithColor(color: NSColor.white)
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



    override func mouseDown(with event: NSEvent) {
//        super.mouseDown(with: event)

        layer?.backgroundColor = activeBackground.cgColor
        layer?.transform = CATransform3DMakeScale(0.92, 0.92, 1)

    }

    override func mouseUp(with event: NSEvent) {
//        super.mouseUp(with: event)

        layer?.backgroundColor = background.cgColor
        layer?.transform = CATransform3DIdentity
    }
}


