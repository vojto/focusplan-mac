//
//  EditableTableCellView.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 4/26/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit

class EditableTableCellView: NSTableCellView, NSTextFieldDelegate {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textField?.delegate = self
    }
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        self.finishEditing()
    }
    
    override func controlTextDidChange(_ obj: Notification) {
    }
    
    func startEditing() {
        guard let field = textField else { return }
        
        field.isEditable = true
        window?.makeFirstResponder(field)
        
        rowView?.isEditing = true
    }
    
    func finishEditing() {
        guard let field = textField else { return }
        
        field.resignFirstResponder()
        field.isEditable = false
        
        rowView?.isEditing = false
    }
    
    var rowView: EditableTableRowView? {
        if let rowView = self.superview as? EditableTableRowView {
            return rowView
        }
        
        return nil
    }
}
