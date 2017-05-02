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
import Hue

class CalendarCollectionItem: NSCollectionViewItem {
    
    let event = MutableProperty<CalendarEvent?>(nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.layer = CALayer()
        view.wantsLayer = true
        view.layer?.borderWidth = 0.5
        view.layer?.cornerRadius = 2.0
        
        guard let field = textField else { return assertionFailure() }
        
        let eventType = event.map { $0?.type }.skipRepeats { $0 == $1 }
        
        let task = event.producer.map { event -> Task? in
            guard let event = event else { return nil }
            
            switch event.type {
            case .task:
                return event.task
            case .timerEntry:
                return event.timerEntry?.task
            }
        }
        
        let project = task.pick { $0.reactive.project.producer }
        let projectColor = project.pick { $0.reactive.color.producer }
        
        SignalProducer.combineLatest(eventType.producer, projectColor.producer).startWithValues { type, colorName in
            guard let color = Palette.decode(colorName: colorName) else { return }
            
            let view = self.view
            
            guard let type = type else { return }
            
            switch type {
            case .task:
                let color1 = color.addHue(0, saturation: -0.3, brightness: 0.2, alpha: -0.9)
                let borderColor = color.addHue(0, saturation: -0.3, brightness: 0.2, alpha: -0.2)
                
                let textColor = color.addHue(0, saturation: -0.2, brightness: -0.2, alpha: 0)
                
                view.layer?.backgroundColor = color1.cgColor
                view.layer?.borderColor = borderColor.cgColor
                
                field.textColor = textColor
                
                break
            case .timerEntry:
                
                let color1 = color.addHue(0, saturation: -0.3, brightness: 0.2, alpha: -0.2)
                
                
                view.layer?.backgroundColor = color1.cgColor
                view.layer?.borderColor = color1.cgColor
                
                field.textColor = color
                
                //                field.textColor = NSColor.white
                break
            }
        }
    
        
        let taskTitle = task.pick { $0.reactive.title }
        

        field.reactive.stringValue <~ taskTitle.map { $0 ?? "" }
        
    }
    
    
    
}
