//
//  NiceClickGestureRecognizer.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 6/29/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Cocoa

class NiceClickGestureRecognizer: NSClickGestureRecognizer {
    override func mouseDown(with event: NSEvent) {
        Swift.print("mouse down!")
        
        super.mouseDown(with: event)
    }
    
    override func mouseUp(with event: NSEvent) {
        Swift.print("mouse up!")
        
        super.mouseUp(with: event)
    }
}
