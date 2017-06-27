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
import NiceKit

class TaskEstimateTableCellView: EditableTableCellView {
    var task = MutableProperty<Task?>(nil)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        guard let field = textField else { return }
        
        let minutesLabel = task.producer.pick({ $0.reactive.estimatedMinutesFormatted.producer })
        
        field.reactive.stringValue <~ minutesLabel.map({ $0 ?? "" })
    }
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        super.controlTextDidEndEditing(obj)
        
        let value = textField?.stringValue ?? ""
        self.task.value?.setEstimate(fromString: value)
    }
}
