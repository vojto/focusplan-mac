//
//  TaskTitleTableCellView.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 4/26/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit
import ReactiveSwift

class TaskTitleTableCellView: NSTableCellView, NSTextFieldDelegate {
    var task = MutableProperty<Task?>(nil)
    
    var controller: TasksViewController?
    
    static let font = NSFont.systemFont(ofSize: 14)
    
    override func awakeFromNib() {
        if let field = textField {
            field.reactive.stringValue <~ task.producer.pick({ $0.reactive.title.producer }).map { $0 ?? "" }
            field.delegate = self
            
            field.font = TaskTitleTableCellView.font
        }
    }
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        guard let field = obj.object as? NSTextField else { return }
        field.isEditable = false
        let value = field.stringValue
        
        task.value?.title = value
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        controller?.updateHeight(cellView: self)
    }
}
