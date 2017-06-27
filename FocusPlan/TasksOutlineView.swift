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
    override func awakeFromNib() {
        self.columnAutoresizingStyle = .firstColumnOnlyAutoresizingStyle
    }
    
    override func mouseDown(with event: NSEvent) {
        let point    = convert(event.locationInWindow, from: nil)
        let rowIndex = row(at: point)
        let columnIndex = column(at: point)
        let selectedIndex = selectedRow

        super.mouseDown(with: event)
        
        let finalPoint = convert(window!.mouseLocationOutsideOfEventStream, from: nil)
//        let finalRowIndex = row(at: finalPoint)
        
        let deltaX = abs(finalPoint.x - point.x)
        let deltaY = abs(finalPoint.y - point.y)
        
        if deltaX < 2, deltaY < 2, rowIndex == selectedIndex {
            edit(at: rowIndex, column: columnIndex)
        }
    }
    
    override func rightMouseDown(with event: NSEvent) {
        let point    = convert(event.locationInWindow, from: nil)
        let rowIndex = row(at: point)
        
        if !selectedRowIndexes.contains(rowIndex) {
            select(row: rowIndex)
        }
        
        NSMenu.popUpContextMenu(menu!, with: event, for: self)
    }
    
    override func menu(for event: NSEvent) -> NSMenu? {
        return nil
    }
    
}
