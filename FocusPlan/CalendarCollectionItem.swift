//
//  CalendarCollectionItem.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 4/28/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Cocoa
import ReactiveSwift

class CalendarCollectionItem: NSCollectionViewItem {
    
    let task = MutableProperty<Task?>(nil)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

        view.layer = CALayer()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor(hexString: "f1f7fd")?.cgColor
        view.layer?.borderColor = NSColor(hexString: "4A90E2")?.cgColor
        view.layer?.borderWidth = 0.5
        view.layer?.cornerRadius = 2.0
        
        
        
        let title = task.producer.pick({ $0.reactive.title.producer }).map { $0 ?? "" }
        
        if let field = textField {
            Swift.print("Setting up the field: \(field)")
            
            field.reactive.stringValue <~ title
        }
    }
    
    
    
}
