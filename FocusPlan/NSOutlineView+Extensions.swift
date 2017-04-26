//
//  NSOutlineView+Extensions.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 4/26/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit

extension NSOutlineView {
    func edit(at row: Int, column: Int) {
        if row == -1 {
            return
        }
        
        guard let view = self.view(atColumn: column, row: row, makeIfNecessary: false) as? EditableTableCellView else { return }
        view.startEditing()
    }
}
