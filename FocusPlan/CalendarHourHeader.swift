//
//  CalendarHourHeader.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/1/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit
import Cartography

class CalendarHourHeader: NSView, NSCollectionViewElement {
    @IBOutlet weak var textField: NSTextField!

    override func awakeFromNib() {
        textField.alignment = .right

        constrain(textField) { field in
//            field.centerY == field.superview!.centerY
            field.top == field.superview!.top + 4
            field.left == field.superview!.left + 8
            field.width == 32.0
        }
    }


    override func draw(_ dirtyRect: NSRect) {
        let size = bounds.size
        let lineRect = NSRect(x: 0, y: size.height - 1, width: size.width, height: 1)

        Stylesheet.secondaryBorder.setFill()

        NSRectFill(lineRect)
    }
}
