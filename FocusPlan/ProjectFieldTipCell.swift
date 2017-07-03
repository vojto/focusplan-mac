//
//  ProjectFieldTipCell.swift
//  Timelist
//
//  Created by Vojtech Rinik on 6/17/17.
//  Copyright © 2017 Vojtech Rinik. All rights reserved.
//

import Cocoa
import Cartography

class ProjectFieldTipCell: NSTableCellView {
    
    let field = NSTextField()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    func setup() {
        self.layer = CALayer()
        self.wantsLayer = true
        layer?.cornerRadius = 4.0
        
        
        field.isEditable = false
        field.isBordered = false
        field.textColor = NSColor.white
        field.drawsBackground = false
        field.stringValue = "bazinga"
        
//        field.setContentHuggingPriority(.required, for: .horizontal)
        field.lineBreakMode = .byTruncatingTail
        
//        include(field, inset: 4.0)
//        include(field, insets: NSEdgeInsets(top: 4.0, left: 8.0, bottom: 4.0, right: 8.0))
        addSubview(field)
        
        constrain(field) { field in
            field.left == field.superview!.left + 8.0
            field.right == field.superview!.right + 8.0
            field.centerY == field.superview!.centerY
        }
        
    }
    
    // Highlighting
    
    
    
    /*
    var isHighlihgted = false {
        didSet {
            if isHighlihgted {
                layer?.backgroundColor = NSColor("5d9cf5")!.cgColor
            } else {
                layer?.backgroundColor = nil
            }
        }
    }
     */
}
