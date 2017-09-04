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

    // Other views
    let timerView = CalendarTimerView()

    // Properties
    let style = MutableProperty<CalendarCollectionItemStyle>(.regular)
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
            isHovered.producer,
            style.producer
            ).map { (running, hovered, style) -> Bool in
                switch style {
                case .regular:
                    return running || hovered
                case .small:
                    return false
                }
        }

        timerView.reactive.isHidden <~ isTimerVisible.map { !$0 }

        style.producer.startWithValues { _ in
            self.applyStyle()
        }

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
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        drawBackground()

        drawHandle()
    }

    // MARK: - Style (regular or small)
    // ------------------------------------------------------------------------

    func applyStyle() {
    }

    // MARK: - Drag and drop for resizing
    // ------------------------------------------------------------------------
    
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

        if let area = trackingArea {
            removeTrackingArea(area)
        }

        trackingArea = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeInKeyWindow], owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea!)
    }

    override func mouseEntered(with event: NSEvent) {
        isHovered.value = true
    }

    override func mouseExited(with event: NSEvent) {
        isHovered.value = false
    }
    
    
}
