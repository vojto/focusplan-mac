//
//  CalendarCollectionItemView.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/3/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Cocoa
import Hue

class CalendarCollectionItemView: NSView {
    
    var background = NSColor.yellow { didSet { needsDisplay = true } }
    var border = NSColor.blue { didSet { needsDisplay = true } }
    var isDashed = false { didSet { needsDisplay = true } }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let path = NSBezierPath(roundedRect: bounds.insetBy(dx: 0.5, dy: 0.5), cornerRadius: 2.0)
        
        background.setFill()
        path.fill()
        
        if isDashed {
            let dashes: [CGFloat] = [4.0, 2.0]
            path.setLineDash(dashes, count: dashes.count, phase: 0)
        }
        
        path.lineWidth = 1
        
        border.setStroke()
        path.stroke()

        
    }
    
}