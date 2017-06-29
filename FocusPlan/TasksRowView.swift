//
//  TasksRowView.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 4/26/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit
import NiceKit


class TasksRowView: CustomTableRowView {
    override open func drawBackground(in dirtyRect: NSRect) {
        let rect = bounds.insetBy(dx: 4, dy: 4)
        let path = NSBezierPath(roundedRect: rect, cornerRadius: 3)
        let blue = NSColor(hexString: "EBEDEE")!
        
        if isEditing {
//            NSColor.white.set()
//            NSRectFill(bounds)
            
            blue.setStroke()
            path.stroke()
        } else if isSelected {
//            NSColor.white.set()
//            NSRectFill(bounds)
            
            blue.setFill()
            path.fill()
        } else {
//            NSColor.orange.set()
//            NSRectFill(bounds)
        }
    }
}
