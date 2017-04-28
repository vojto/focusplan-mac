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

class TaskTitleTableCellView: EditableTableCellView {
    var task = MutableProperty<Task?>(nil)
    
    @IBOutlet var finishedButton: NSButton?
    
    var controller: TasksViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let isFinished = task.producer.pick({ $0.reactive.isFinished.producer })
        let isPlanned = task.producer.pick({ $0.reactive.isPlanned.producer })
        
        if let field = textField {
            field.reactive.stringValue <~ task.producer.pick({ $0.reactive.title.producer }).map { $0 ?? "" }
            
            isFinished.startWithValues { finished in
                self.superview?.alpha = (finished ?? false) ? 0.4 : 1
            }
            
            SignalProducer.combineLatest(isEditing.producer, isPlanned.producer)
                .startWithValues { editing, planned in
                    let normal = NSFont.systemFont(ofSize: 14, weight: NSFontWeightRegular)
                    let medium = NSFont.systemFont(ofSize: 14, weight: NSFontWeightMedium)
                    
                    if editing {
                        field.font = normal
                    } else if (planned ?? false) {
                        field.font = medium
                    } else {
                        field.font = normal
                    }
            }
        }
        
        if let button = finishedButton {
            button.reactive.image <~ isFinished.map { finished -> NSImage in
                if (finished ?? false) {
                    return #imageLiteral(resourceName: "TaskChecked")
                } else {
                    return #imageLiteral(resourceName: "TaskUnchecked")
                }
            }
        }
    }
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        super.controlTextDidEndEditing(obj)
        
        guard let field = obj.object as? NSTextField else { return }
        let value = field.stringValue
        
        task.value?.title = value
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        super.controlTextDidChange(obj)
        
        controller?.updateHeight(cellView: self)
    }
    
    @IBAction func toggleFinished(_ sender: Any) {
        if let task = self.task.value {
            task.isFinished = !task.isFinished
        }
    }
}
