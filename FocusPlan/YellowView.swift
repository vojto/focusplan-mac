//
//  YellowView.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/8/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit

class YellowView: NSView {
    override func draw(_ dirtyRect: NSRect) {
        NSColor.yellow.set()
        NSRectFill(bounds)
    }
}
