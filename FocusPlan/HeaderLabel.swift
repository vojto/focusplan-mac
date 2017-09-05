//
//  HeaderLabel.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 9/5/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Cocoa
import Cartography

class HeaderLabel: NSTextField {

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    convenience init(text: String) {
        self.init(frame: NSRect.zero)
        stringValue = text
    }

    func setup() {
        isBordered = false
        isEditable = false
        isSelectable = false
        stringValue = ""
        drawsBackground = false
        font = NSFont.systemFont(ofSize: 24, weight: NSFontWeightMedium)
        textColor = NSColor(hexString: "38393A")!
    }

    func addToHeaderRow(view: NSView) {
        view.addSubview(self)

        constrain(self) { title in
            title.left == title.superview!.left + 20
            title.bottom == title.superview!.bottom - 20
        }
    }
    
}
