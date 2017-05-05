//
//  SelectingTextField.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/5/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Cocoa

class SelectingTextField: NSTextField {

    var wantsSelectAll = false

    override func becomeFirstResponder() -> Bool {
        wantsSelectAll = true
        
        return super.becomeFirstResponder()
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        
        if wantsSelectAll {
            selectText(self)
            wantsSelectAll = false
        }
    }
}
