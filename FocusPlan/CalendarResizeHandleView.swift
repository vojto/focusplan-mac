//
//  CalendarResizeHandleView.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 7/4/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit

class CalendarResizeHandleView: NSView {
    override func draw(_ dirtyRect: NSRect) {
        let color = NSColor.black.alpha(0.5)

        color.setFill()

        NSRectFill(bounds)
    }
}
