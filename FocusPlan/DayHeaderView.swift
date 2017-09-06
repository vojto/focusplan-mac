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

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setup()
    }

    func setup() {
        let label = NSTextField(labelWithString: "day label")
        addSubview(label)

        constrain(label) { label in
            label.center == label.superview!.center
        }

    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.yellow.set()
        NSRectFill(bounds.insetBy(dx: 5.0, dy: 5.0))
    }
    
}
