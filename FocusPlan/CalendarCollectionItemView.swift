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
    var isHighlighted = false { didSet { needsDisplay = true } }
    
    var onDoubleClick: (() -> ())?

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let path = NSBezierPath(roundedRect: bounds.insetBy(dx: 0.5, dy: 0.5), cornerRadius: 2.0)
        
        var background = self.background
        
        if isHighlighted {
            background = background.addHue(0, saturation: 0.1, brightness: -0.2, alpha: 0)
        }
        
        background.setFill()
        path.fill()
        
        if isDashed {
            let dashes: [CGFloat] = [4.0, 2.0]
            path.setLineDash(dashes, count: dashes.count, phase: 0)
        }
        
        path.lineWidth = 0.5
        
        border.setStroke()
        path.stroke()
    }
    
    override func mouseDown(with event: NSEvent) {
        if event.clickCount == 2 {
            onDoubleClick?()
        } else {
            super.mouseDown(with: event)
        }
    }
    
}
