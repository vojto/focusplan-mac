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
    
    var wantsHighlightPlanned = true
    
    var controller: TasksViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let isFinished = task.producer.pick({ $0.reactive.isFinished.producer })
        let isPlanned = task.producer.pick({ $0.reactive.isPlanned.producer })
        let project = task.producer.pick({ $0.reactive.project.producer })
        
        guard let field = textField else { return assertionFailure() }
        
        let title = task.producer.pick({ $0.reactive.title.producer }).map { $0 ?? "" }
        
        let attributedTitle = SignalProducer.combineLatest(title, isFinished).map { title, isFinished -> NSAttributedString in
            var attributes = [String: Any]()
            
            if (isFinished ?? false) {
                attributes[NSStrikethroughStyleAttributeName] = NSUnderlineStyle.styleSingle.rawValue
            }
            
            return NSAttributedString(string: title, attributes: attributes)
        }

        field.reactive.attributedStringValue <~ attributedTitle
        
        SignalProducer.combineLatest(isEditing.producer, isPlanned.producer, project.producer)
            .startWithValues { editing, planned, project in
                let normal = NSFont.systemFont(ofSize: 14, weight: NSFontWeightRegular)
                let medium = NSFont.systemFont(ofSize: 14, weight: NSFontWeightMedium)
                
                /*
                if editing {
                    field.font = normal
                    field.textColor = NSColor.labelColor
                } else if (planned ?? false) && self.wantsHighlightPlanned {
                    field.font = medium
                    
                    if let color = project?.color,
                        let nsColor = Palette.decode(colorName: color) {
                        field.textColor = nsColor
                    } else {
                        field.textColor = NSColor.labelColor
                    }
                } else {
                    field.font = normal
                    field.textColor = NSColor.labelColor
                }
                */
        }
        
        
        guard let button = finishedButton else { return assertionFailure() }
    

        button.reactive.image <~ isFinished.map { finished -> NSImage in
            if (finished ?? false) {
                return #imageLiteral(resourceName: "TaskChecked")
            } else {
                return #imageLiteral(resourceName: "TaskUnchecked")
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
