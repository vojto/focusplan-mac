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
        
//        if isHighlighted {
//            background = background.addHue(0, saturation: 0.1, brightness: -0.2, alpha: 0)
//        }
        
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
            let point = convert(event.locationInWindow, from: nil)
            
            if topResizeFrame.contains(point) || bottomResizeFrame.contains(point) {
                resize(event: event)
            } else {
                super.mouseDown(with: event)
            }
        }
    }
    
    var onBeforeResize: (() -> ())?
    var onResize: ((CGFloat) -> ())?
    var onFinishResize: (() -> ())?
    
    func resize(event: NSEvent) {
        var keepOn = true
        
        let initialLocation = event.locationInWindow
        
        onBeforeResize?()
        
        while keepOn {
            let event = window!.nextEvent(matching: [.leftMouseUp, .leftMouseDragged])!
            
            let location = event.locationInWindow
            
            let deltaY = initialLocation.y - location.y
            
            switch event.type {
            case .leftMouseDragged:
                self.onResize?(deltaY)
                
                break
            case .leftMouseUp:
                // TODO: Call finished callback
                
                onFinishResize?()

                keepOn = false
            default:
                assertionFailure()
                break
            }
        }
    }
    
    // MARK: - Cursor rects
    // -----------------------------------------------------------------------
    
    var topResizeFrame = NSZeroRect
    var bottomResizeFrame = NSZeroRect
    
    override func resetCursorRects() {
        super.resetCursorRects()
        
        let topCursor = NSCursor.resizeDown()
        var topFrame = self.frame
        topFrame.origin.y = topFrame.size.height - 5
        topFrame.size.height = 5
        addCursorRect(topFrame, cursor: topCursor)
        topResizeFrame = topFrame
        
        let bottomCursor = NSCursor.resizeUp()
        var bottomFrame = self.frame
        bottomFrame.origin.y = 0
        bottomFrame.size.height = 5
        addCursorRect(bottomFrame, cursor: bottomCursor)
        bottomResizeFrame = bottomFrame
    }
    
}
