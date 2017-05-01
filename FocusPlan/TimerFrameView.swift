//
//  TimerFrameView.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/1/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit

class TimerFrameView: NSView {
    override func awakeFromNib() {
        self.wantsLayer = true
        
        layer?.backgroundColor = NSColor(hexString: "F9F9F9")?.cgColor
        layer?.cornerRadius = 4.0
        layer?.borderColor = NSColor(hexString: "C5C5C5")?.cgColor
        layer?.borderWidth = 1.0
    }
}
