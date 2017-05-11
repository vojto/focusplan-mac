//
//  ProjectsOutlineView.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 4/25/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit

class ProjectsOutlineView: NSOutlineView {
    override open func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        
        let point    = convert(event.locationInWindow, from: nil)
        let rowIndex = row(at: point)
        
//        if rowIndex <= 0 {
//            // TODO: Finish editing
//            self.window!.makeFirstResponder(nil)
//        }
        
        
        if event.clickCount == 2 {
            if rowIndex >= 1 {
                edit(at: rowIndex, column: 0)
            }
        }
    }

}
