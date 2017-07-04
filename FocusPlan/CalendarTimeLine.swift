//
//  CalendarTimeLine.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/1/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit

class CalendarTimeLine: NSView, NSCollectionViewElement {
    override func draw(_ dirtyRect: NSRect) {
        let color = NSColor(hexString: "D42727")!
        color.setStroke()
        color.setFill()
        
        let triangleHeight = bounds.size.height
        let triangleWidth: CGFloat = 6.0
        
        let triangle = NSBezierPath()
        triangle.move(to: NSPoint(x: 0, y: 0))
        triangle.line(to: NSPoint(x: triangleWidth, y: triangleHeight / 2))
        triangle.line(to: NSPoint(x: 0, y: triangleHeight))
        triangle.line(to: NSPoint(x: 0, y: 0))
        triangle.close()
        
        triangle.fill()
        
        let lineY = bounds.size.height / 2
        let bezierPath = NSBezierPath()
        bezierPath.move(to: NSPoint(x: 0, y: lineY))
        bezierPath.line(to: NSPoint(x: bounds.size.width, y: lineY))
        //        NSColor.black.setStroke()
        
        bezierPath.lineWidth = 1
//        bezierPath.setLineDash([1, 1], count: 2, phase: 0)
//        bezierPath.stroke()
    }
}
