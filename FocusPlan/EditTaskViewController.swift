//
//  EditTaskViewController.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/5/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Cocoa
import ReactiveSwift

class EditTaskViewController: NSViewController, NSTextFieldDelegate {
    
    let task = MutableProperty<Task?>(nil)
    
    var onFinishEditing: (() -> ())?
    
    @IBOutlet weak var titleField: SelectingTextField!
    @IBOutlet weak var estimateField: SelectingTextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTitleField()
        
        setupEstimateField()
    }
    
    func setupTitleField() {
        titleField.delegate = self
        
        titleField.reactive.stringValue <~ task.producer.pick({
            $0.reactive.title.producer
        }).map { $0 ?? "" }
        
        titleField.reactive.stringValues.observeValues { title in
            self.task.value?.title = title
        }
    }
    
    func setupEstimateField() {
        estimateField.delegate = self
        
        estimateField.reactive.stringValue <~ task.producer.pick({
            $0.reactive.estimatedMinutesFormatted.producer
        }).map({ $0 ?? "" })
        
        estimateField.reactive.stringValues.observeValues { value in
            self.task.value?.setEstimate(fromString: value)
        }
    }
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.insertNewline(_:)) {
            onFinishEditing?()
            
            return true
        }
        
        return false
    }
}
