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

    func setup() {
        let layer = CALayer()

        layer.backgroundColor = NSColor(calibratedWhite: 0, alpha: 0.1).cgColor
        layer.cornerRadius = 3.0

        self.layer = layer
        self.wantsLayer = true


        let stack = NSStackView()
        stack.orientation = .horizontal

        label.textColor = NSColor.white
        label.font = NSFont.systemFont(ofSize: 13).monospaced()
        label.stringValue = "0:00"

        stack.setViews([imageView, label], in: .leading)

        include(stack, inset: 4.0)
    }
}
