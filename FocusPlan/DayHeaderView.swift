//
//  DayHeaderView.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 9/6/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Cocoa
import Cartography

class DayHeaderView: NSView {

    var date = Date() { didSet { update() } }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setup()
    }

    let primaryLabel = NSTextField(labelWithString: "")
    let secondaryLabel = NSTextField(labelWithString: "")

    func setup() {
        primaryLabel.font = NSFont.systemFont(ofSize: 14.0, weight: NSFontWeightRegular)
        primaryLabel.textColor = NSColor(hex: "b1b3b8")

        secondaryLabel.font = NSFont.systemFont(ofSize: 14.0, weight: NSFontWeightRegular)
        secondaryLabel.textColor = NSColor(hex: "d3d4d7")


        let spacer = NSView()

        let stack = NSStackView(views: [primaryLabel, spacer, secondaryLabel])
        stack.orientation = .horizontal

        include(stack)
    }

    func update() {
        primaryLabel.stringValue = date.string(custom: "E")
        secondaryLabel.stringValue = date.string(custom: "d")
    }
    
}
