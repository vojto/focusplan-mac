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
        let title = HeaderLabel()
        title.addToHeaderRow(view: self)

        self.textField = title

        /*
        let picker = ColorPicker()
        addSubview(picker)

        constrain(picker, title) { view, title in
            view.width == 20.0
            view.height == 20.0

            view.left == title.right + 8.0
            view.centerY == title.centerY

        }
         */
    }
}
