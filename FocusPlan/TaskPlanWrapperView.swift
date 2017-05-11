//
//  TaskPlanWrapperView.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/11/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit

class TaskPlanWrapperView: NSView {
    var wantsHighlight: Bool = false {
        didSet {
            update()
        }
    }
    
    override func awakeFromNib() {
        wantsLayer = true
        
        update()
    }
    
    func  update() {
        if wantsHighlight {
            layer?.backgroundColor = NSColor(hexString: "FFFBBC")!.cgColor
            layer?.cornerRadius = 4.0
        } else {
            layer?.backgroundColor = nil
        }
    }
}
