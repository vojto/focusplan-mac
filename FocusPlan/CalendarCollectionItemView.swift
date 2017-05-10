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
    
    enum HandleType {
        case top
        case bottom
    }
    
    var background = NSColor.yellow { didSet { needsDisplay = true } }
    var border = NSColor.blue { didSet { needsDisplay = true } }
    var isDashed = false { didSet { needsDisplay = true } }
    var isHighlighted = false { didSet { needsDisplay = true } }
    
    var backgroundProgress = 1.0
    
    var onDoubleClick: (() -> ())?
    var onBeforeResize: (() -> ())?
    var onResize: ((CGFloat, HandleType) -> ())?
    var onFinishResize: ((HandleType) -> ())?

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let cornerRadius: CGFloat = 2.0
        let bounds = self.bounds.insetBy(dx: 0.5, dy: 0.5)
        
        let path = NSBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        
        background.setFill()
        path.fill()
        
        
        let darkerBackground = background.addHue(0, saturation: 0, brightness: -0.2, alpha: 0)
        var darkerBounds = bounds
        let newHeight = bounds.size.height * CGFloat(backgroundProgress)
        darkerBounds.origin.y += darkerBounds.size.height - newHeight
        darkerBounds.size.height = newHeight
        let darkerPath = NSBezierPath(roundedRect: darkerBounds, cornerRadius: cornerRadius)
        darkerBackground.setFill()
        darkerPath.fill()
        
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
            
            if topResizeFrame.contains(point) {
                resize(event: event, handle: .top)
            } else if bottomResizeFrame.contains(point) {
                resize(event: event, handle: .bottom)
            } else {
                super.mouseDown(with: event)
            }
        }
    }
    
    func resize(event: NSEvent, handle: HandleType) {
        var keepOn = true
        
        let initialLocation = event.locationInWindow
        
        onBeforeResize?()
        
        while keepOn {
            let event = window!.nextEvent(matching: [.leftMouseUp, .leftMouseDragged])!
            
            let location = event.locationInWindow
            
            let deltaY = initialLocation.y - location.y
            
            switch event.type {
            case .leftMouseDragged:
                self.onResize?(deltaY, handle)
                
                break
            case .leftMouseUp:
                // TODO: Call finished callback
                
                onFinishResize?(handle)

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
        var topFrame = self.bounds
        topFrame.origin.y = topFrame.size.height - 5
        topFrame.size.height = 5
        addCursorRect(topFrame, cursor: topCursor)
        topResizeFrame = topFrame
        
        let bottomCursor = NSCursor.resizeUp()
        var bottomFrame = self.bounds
        bottomFrame.origin.y = 0
        bottomFrame.size.height = 5
        addCursorRect(bottomFrame, cursor: bottomCursor)
        bottomResizeFrame = bottomFrame
    }
    
    
}
