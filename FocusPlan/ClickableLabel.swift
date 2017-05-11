//
//  ClickableLabel.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/11/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit

class ClickableLabel: NSTextField {
    
    var onDoubleClick: (() -> ())?
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        
        if event.clickCount == 2 {
            onDoubleClick?()
        }
    }
}
