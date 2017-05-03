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
        
        let view = self.view as! CalendarCollectionItemView
        
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
            
            guard let type = type else { return }
            
            field.alpha = 1
            view.isDashed = false
            
            switch type {
            case .task:
                guard let color = Palette.decode(colorName: colorName) else { return }
                let color1 = color.addHue(0, saturation: -0.3, brightness: 0.2, alpha: -0.9)
                let borderColor = color.addHue(0, saturation: -0.3, brightness: 0.2, alpha: -0.2)
                
                let textColor = color.addHue(0, saturation: -0.2, brightness: -0.2, alpha: 0)
                
                view.background = color1
                view.border = borderColor
                view.isDashed = true
                
                field.textColor = textColor
                field.stringValue = self.event.value?.task?.title ?? ""
                
                break
            case .timerEntry:

                guard let entry = self.event.value?.timerEntry else { return }
                guard let lane = LaneId(rawValue: entry.lane ?? "") else { return }
                
                switch lane {
                case .pomodoro:
                    guard let type = PomodoroType(rawValue: entry.type ?? "") else { return }
                    
                    switch type {
                    case .pomodoro:
                        let red = NSColor(hexString: "FE9097")!
                        view.background = red
                        view.border = red
                        field.textColor = NSColor.white
                        field.stringValue = "Pomodoro"
                        field.alpha = 0.85
                    case .shortBreak, .longBreak:
                        let green = NSColor(hexString: "9BDDB6")!
                        view.background = green
                        view.border = green
                        field.textColor = NSColor.white
                        field.stringValue = "Break"
                        field.alpha = 0.85
                    }
                case .general:
                    guard let color = Palette.decode(colorName: colorName) else { return }
                    let color1 = color.addHue(0, saturation: -0.3, brightness: 0.2, alpha: -0.2)
                    view.background = color1
                    view.border = color1
                    field.textColor = color
                    field.stringValue = self.event.value?.timerEntry?.task?.title ?? ""
                }
                
                break
            }
        }
    
        
//        let taskTitle = task.pick { $0.reactive.title }
        

//        field.reactive.stringValue <~ taskTitle.map { $0 ?? "" }
        
    }
    
    
    
}
