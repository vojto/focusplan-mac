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
    
    @IBOutlet weak var titleField: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleField.delegate = self
        
        let title = task.producer.pick({ $0.reactive.title.producer })
        
        titleField.reactive.stringValue <~ title.map { $0 ?? "" }
        
        titleField.reactive.stringValues.observeValues { title in
            self.task.value?.title = title
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
