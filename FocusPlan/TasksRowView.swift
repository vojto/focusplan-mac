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
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    let highlightView = NSView()
    let highlightLayer = CALayer()
    
    func setup() {
        
        highlightLayer.cornerRadius = 2.0
        highlightLayer.actions = [
            "backgroundColor": NSNull()
        ]
        
        highlightView.layer = highlightLayer
        highlightView.wantsLayer = true
        
        self.include(highlightView, inset: 4.0)
        
    }
    
    override var isSelected: Bool {
        didSet {
            updateHighlightLayer()
        }
    }
    
    override var isEditing: Bool {
        didSet {
            updateHighlightLayer()
        }
    }
    
    func updateHighlightLayer() {
        let white = NSColor.white.cgColor
        let blue = NSColor(hexString: "EBEDEE")!.cgColor
        let clear = NSColor.clear.cgColor
        
        highlightLayer.shadowColor = nil
        highlightLayer.shadowOffset = CGSize(width: 0, height: 0)
        highlightLayer.shadowRadius = 0
        
        Swift.print("🌼 Updating highlight layer!")
        
        if isEditing {
            Swift.print("Editing!")
            
            highlightLayer.backgroundColor = white
            highlightLayer.shadowColor = NSColor(calibratedWhite: 0, alpha: 1).cgColor
            highlightLayer.shadowOffset = CGSize(width: 0, height: -2)
            highlightLayer.shadowOpacity = 0.2
            highlightLayer.shadowRadius = 3.0
        } else if isSelected {
            Swift.print("Selected!")
            
            highlightLayer.backgroundColor = blue
        } else {
            Swift.print("Nothing!")
            
            highlightLayer.backgroundColor = clear
        }
        
        
    }
    
    override open func drawBackground(in dirtyRect: NSRect) {
        /*
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
         */
    }
}
