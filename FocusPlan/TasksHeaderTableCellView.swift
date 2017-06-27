//
//  TasksHeaderTableCellView.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 6/27/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Cocoa
import Cartography

class TasksHeaderTableCellView: NSTableCellView {

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    func setup() {
        
        Swift.print("🌈 Setting up TasksHeaderTableCellView!")
        
        let title = NSTextField()
        title.isBordered = false
        title.isEditable = false
        title.isSelectable = false
        title.stringValue = "bazinga"
        title.drawsBackground = false
        title.font = NSFont.systemFont(ofSize: 24, weight: NSFontWeightMedium)
        title.textColor = NSColor(hexString: "38393A")!
        addSubview(title)
        
        constrain(title) { title in
            title.left == title.superview!.left + 20
            title.bottom == title.superview!.bottom - 20
        }
        
        self.textField = title
    }
}
