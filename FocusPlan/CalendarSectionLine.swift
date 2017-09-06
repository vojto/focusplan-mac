//
//  CalendarSectionLine.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/3/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit

class CalendarSectionLine: NSView, NSCollectionViewElement {
    override func draw(_ dirtyRect: NSRect) {
        Stylesheet.secondaryBorder.set()

        
        let lineRect = NSRect(x: 0, y: 0, width: 1, height: bounds.size.height)
        
        NSRectFill(lineRect)
    }
}
