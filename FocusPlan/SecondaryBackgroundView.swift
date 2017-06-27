//
//  SecondaryBackgroundView.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 6/27/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Cocoa

class SecondaryBackgroundView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let color1 = NSColor(hexString: "F8F9FA")!
        let color2 = NSColor(hexString: "FFFFFF")!
        
        let gradient = NSGradient(colors: [color1, color2])
        
        gradient?.draw(in: bounds, angle: -90)
    }
    
}
