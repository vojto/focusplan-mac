//
//  TasksOutlineView.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 4/26/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit
import NiceKit

class TasksOutlineView: EditableOutlineView {
    var monitor: Any?

    override func awakeFromNib() {
        self.columnAutoresizingStyle = .firstColumnOnlyAutoresizingStyle

        self.monitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown]) { event in
            if event.window != self.window {
                return event
            }

            if let view = self.editedCellView {
                let loc = view.convert(event.locationInWindow, from: nil)
                let result = view.hitTest(loc)

                if result == nil {
                    (view as? TaskTitleTableCellView)?.forceFinishEditing()
                    return nil
                }

            }

            return event
        }
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
    
    // MARK: - Editing
    
    override func edit(at row: Int, column: Int) {
        if row == -1 {
            return
        }
        
        let view = self.view(atColumn: column, row: row, makeIfNecessary: false)
        
        if let titleView = view as? TaskTitleTableCellView {
            titleView.startEditing()
        }
    }

    func finishEditingAndExecute(callback: @escaping (() -> ())) {
        if let editedCell = editedCellView as? TaskTitleTableCellView {
            editedCell.forceFinishEditing() {
                callback()
            }
        } else {
            callback()
        }
    }
    
}
