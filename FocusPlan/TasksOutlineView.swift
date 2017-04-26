//
//  TasksOutlineView.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 4/26/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit

class TasksOutlineView: NSOutlineView {
    override func mouseDown(with event: NSEvent) {
        
        
        let point    = convert(event.locationInWindow, from: nil)
        let rowIndex = row(at: point)
        let selectedIndex = selectedRow


        super.mouseDown(with: event)
        
        if rowIndex == selectedIndex {
            edit(at: rowIndex)
        }
    }
}
