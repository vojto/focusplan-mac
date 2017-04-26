//
//  TasksBackgroundView.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 4/26/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit

class TasksBackgroundView: NSView {
    override func draw(_ dirtyRect: NSRect) {
        NSColor.white.set()
        NSRectFill(bounds)
    }
}
