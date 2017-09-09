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

    let titleLabel = HeaderLabel()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    func setup() {
        titleLabel.addToHeaderRow(view: self)

        self.textField = titleLabel
    }
}
