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
    
    override func frameOfCell(atColumn column: Int, row: Int) -> NSRect {
        var frame = super.frameOfCell(atColumn: column, row: row)
        
        let object = (item(atRow: row) as? NSTreeNode)?.representedObject
        
        if let header = object as? ProjectsViewController.HeaderItem {
            switch header.type {
            case .today, .next:
                frame.origin.x = 0
                frame.size.width = self.frame.size.width
            case .backlog:
                break
            }
        } else if object is ProjectsViewController.ProjectItem {
            frame.origin.x -= self.indentationPerLevel
        }
        
        return frame
    }
 
    
    
    override open func mouseDown(with event: NSEvent) {
        
        super.mouseDown(with: event)
        
        let point    = convert(event.locationInWindow, from: nil)
        let columnIndex = self.column(at: point)
        let rowIndex = row(at: point)
        
        if columnIndex < 0 || rowIndex < 0 {
            return
        }
        
//        if rowIndex <= 0 {
//            // TODO: Finish editing
//            self.window!.makeFirstResponder(nil)
//        }
        
//        let view = self.view(atColumn: columnIndex, row: rowIndex, makeIfNecessary: false)
//        
//        if let cellView = view as? ProjectTableCellView {
//            // tell the cell view to edit or do whatever it wants to do
//            Swift.print("gonna let cell view handle the click: \(cellView)")
//        }
        
//        Swift.print("view is: \(view)")
        
        if event.clickCount == 2 {
            if rowIndex >= 1 {
                edit(at: rowIndex, column: 0)
            }
        }
    }
 
 
}
