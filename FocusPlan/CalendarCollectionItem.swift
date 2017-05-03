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
            let view = self.view
            
            guard let type = type else { return }
            
            field.alpha = 1
            
            switch type {
            case .task:
                guard let color = Palette.decode(colorName: colorName) else { return }
                let color1 = color.addHue(0, saturation: -0.3, brightness: 0.2, alpha: -0.9)
                let borderColor = color.addHue(0, saturation: -0.3, brightness: 0.2, alpha: -0.2)
                
                let textColor = color.addHue(0, saturation: -0.2, brightness: -0.2, alpha: 0)
                
                view.layer?.backgroundColor = color1.cgColor
                view.layer?.borderColor = borderColor.cgColor
                
                field.textColor = textColor
                field.stringValue = self.event.value?.task?.title ?? ""
                
                break
            case .timerEntry:
                Swift.print("🖍")
                Swift.print("Coloring from event: \(self.event)")
                Swift.print("Entry: \(self.event.value?.timerEntry)")
                
                guard let entry = self.event.value?.timerEntry else { return }
                guard let lane = LaneId(rawValue: entry.lane ?? "") else { return }
                
                switch lane {
                case .pomodoro:
                    guard let type = PomodoroType(rawValue: entry.type ?? "") else { return }
                    
                    switch type {
                    case .pomodoro:
                        let red = NSColor(hexString: "DB225D")?.cgColor
                        view.layer?.backgroundColor = red
                        view.layer?.borderColor = red
                        field.textColor = NSColor.white
                        field.stringValue = "Pomodoro"
                        field.alpha = 0.75
                    case .shortBreak, .longBreak:
                        let green = NSColor(hexString: "85D0C0")?.cgColor
                        view.layer?.backgroundColor = green
                        view.layer?.borderColor = green
                        field.textColor = NSColor.white
                        field.stringValue = "Break"
                        field.alpha = 0.75
                    }
                case .general:
                    guard let color = Palette.decode(colorName: colorName) else { return }
                    let color1 = color.addHue(0, saturation: -0.3, brightness: 0.2, alpha: -0.2)
                    view.layer?.backgroundColor = color1.cgColor
                    view.layer?.borderColor = color1.cgColor
                    field.textColor = color
                    field.stringValue = self.event.value?.task?.title ?? ""
                }
                
                break
            }
        }
    
        
//        let taskTitle = task.pick { $0.reactive.title }
        

//        field.reactive.stringValue <~ taskTitle.map { $0 ?? "" }
        
    }
    
    
    
}
