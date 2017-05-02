//
//  CalendarCollectionItem.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 4/28/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Cocoa
import ReactiveSwift
import enum Result.NoError

class CalendarCollectionItem: NSCollectionViewItem {
    
    let event = MutableProperty<CalendarEvent?>(nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.layer = CALayer()
        view.wantsLayer = true
        view.layer?.borderWidth = 0.5
        view.layer?.cornerRadius = 2.0
        
        guard let field = textField else { return assertionFailure() }
        
        field.textColor = NSColor(hexString: "4A90E2")
        
        let eventType = event.map { $0?.type }
        
        eventType.producer.startWithValues { type in
            let view = self.view
            
            guard let type = type else { return }
            
            switch type {
            case .task:
                view.layer?.backgroundColor = NSColor.clear.cgColor
                view.layer?.borderColor = NSColor(hexString: "4A90E2")?.cgColor
                
                
                break
            case .timerEntry:
                view.layer?.backgroundColor = NSColor(hexString: "f1f7fd")?.cgColor
                view.layer?.borderColor = NSColor(hexString: "f1f7fd")?.cgColor
                
//                field.textColor = NSColor.white
                break
            }
        }

        
        let task = event.producer.map { event -> Task? in
            guard let event = event else { return nil }
            
            switch event.type {
            case .task:
                return event.task
            case .timerEntry:
                return event.timerEntry?.task
            }
        }
        
        let taskTitle = task.pick { $0.reactive.title }
        

        field.reactive.stringValue <~ taskTitle.map { $0 ?? "" }
        
    }
    
    
    
}
