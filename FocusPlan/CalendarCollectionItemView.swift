//
//  CalendarCollectionItemView.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/3/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Cocoa
import Hue
import Cartography
import NiceKit
import ReactiveSwift

class CalendarCollectionItemView: NSView {
    
    enum HandleType {
        case top
        case bottom
    }

    let timerView = CalendarTimerView()

    var background = Palette.standard { didSet { needsDisplay = true } }
    var border = NSColor.blue { didSet { needsDisplay = true } }
    var isDashed = false { didSet { needsDisplay = true } }
    var isHighlighted = false { didSet { needsDisplay = true } }

    var isFromTopResizingEnabled = false
    
    var backgroundProgress = 1.0
    
    var onDoubleClick: (() -> ())?
    var onBeforeResize: (() -> ())?
    var onResize: ((CGFloat, HandleType) -> ())?
    var onFinishResize: ((HandleType) -> ())?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        addSubview(timerView)

        constrain(timerView) { timer in
            timer.right == timer.superview!.right - 8
            timer.bottom == timer.superview!.bottom - 8
        }

        let isTimerVisible = SignalProducer.combineLatest(
            timerView.isRunning.producer,
            isHovered.producer
        ).map { running, hovered in
            return running || hovered
        }

        timerView.reactive.isHidden <~ isTimerVisible.map { !$0 }

//        isHovered.producer.startWithValues { hovered in
//            self.alphaValue = hovered ? 0.8 : 1
//        }
    }

    override var frame: NSRect {
        didSet {
            isHovered.value = false
            self.updateTrackingAreas()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        Swift.print("[CalendarCollectionItemView] Preparing for reuse!")

//        updateTrackingAreas()
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let cornerRadius: CGFloat = 4.0
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

        let gradient = NSGradient(colors: [NSColor.white.alpha(0.15), NSColor.white.alpha(0), NSColor.white.alpha(0)])
        let gradientHeight: CGFloat = 200.0
        let gradientRect = NSRect(x: 0, y: bounds.size.height - gradientHeight, width: bounds.size.width, height: gradientHeight)
        gradient?.draw(in: gradientRect, angle: -85)


        // Draw the handle
        for i in 0...1 {
            let handleColor = NSColor.black.alpha(0.35)
            let handleWidth: CGFloat = 32.0
            let handleHeight: CGFloat = 1.0
            let handleSpace: CGFloat = 1.0
            let handleFrame = NSRect(
                x: (bounds.size.width - handleWidth)/2,
                y: 3 + CGFloat(i) * (handleHeight + handleSpace),
                width: handleWidth,
                height: handleHeight
            )

            handleColor.setFill()
            NSRectFillUsingOperation(handleFrame, .sourceOver)
//            NSRectFill(handleFrame)
        }

    }
    
    override func mouseDown(with event: NSEvent) {
        if event.clickCount == 2 {
            onDoubleClick?()
        } else {
            let point = convert(event.locationInWindow, from: nil)

            if isFromTopResizingEnabled && topResizeFrame.contains(point) {
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

        if isFromTopResizingEnabled {
            let topCursor = NSCursor.resizeDown()
            var topFrame = self.bounds
            topFrame.origin.y = topFrame.size.height - 5
            topFrame.size.height = 5
            addCursorRect(topFrame, cursor: topCursor) // Resizing from the top disabled
            topResizeFrame = topFrame
        }

        
        let bottomCursor = NSCursor.resizeUp()
        var bottomFrame = self.bounds
        bottomFrame.origin.y = 0
        bottomFrame.size.height = 10
        addCursorRect(bottomFrame, cursor: bottomCursor)
        bottomResizeFrame = bottomFrame
    }

    // MARK: - Mouse enter/leave events
    // -----------------------------------------------------------------------

    var trackingArea: NSTrackingArea?
    let isHovered = MutableProperty<Bool>(false)

    override open func updateTrackingAreas() {
        super.updateTrackingAreas()

        Swift.print("☂️ Updating tracking areas!")

        if let area = trackingArea {
            removeTrackingArea(area)
        }

        trackingArea = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeInKeyWindow], owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea!)
    }

    override func mouseEntered(with event: NSEvent) {
        Swift.print("Mouse entered!")

        isHovered.value = true
    }

    override func mouseExited(with event: NSEvent) {
        isHovered.value = false
    }
    
    
}
