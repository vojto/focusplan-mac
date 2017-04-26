//
//  TaskEstimateTableCellView.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 4/26/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit
import ReactiveSwift
import ReactiveCocoa

class TaskEstimateTableCellView: NSTableCellView, NSTextFieldDelegate {
    var task = MutableProperty<Task?>(nil)
    
    override func awakeFromNib() {
        guard let field = textField else { return }
        
        field.delegate = self
        
        let minutesLabel = task.producer.pick({ $0.reactive.estimatedMinutes })
            .map { minutes -> String in
                if let minutes = minutes, minutes > 0 {
                    return "\(minutes)m"
                } else {
                    return ""
                }
        }
        
        field.reactive.stringValue <~ minutesLabel
    }
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        let minutes: Int?
        let value = textField?.stringValue ?? ""
        
        if let match = value.match(regex: "^\\s*(\\d+)\\s*m?\\s*$") {
            // "   123   "
            minutes = Int(match[1])
        } else if let match = value.match(regex: "^\\s*(\\d+)\\s*h\\s*$") {
            // "   123   h  "
            minutes = (Int(match[1]) ?? 0) * 60
        } else if let match = value.match(regex: "^\\s*(\\d+)\\s*h\\s*(\\d+)\\s*m?\\s*$") {
            // "   123   h  30m "
            minutes = (Int(match[1]) ?? 0) * 60 + (Int(match[2]) ?? 0)
        } else {
            minutes = nil
        }
        
        self.task.value?.estimatedMinutes = Int64(minutes ?? 0)
    }
}
