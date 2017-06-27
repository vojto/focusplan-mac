//
//  BackgroundView.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/5/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit

class BackgroundView: NSView {
    override func draw(_ dirtyRect: NSRect) {
        NSColor.white.set()
        NSRectFill(bounds)
    }
    
}
