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
    @IBOutlet weak var field: NSTextField!
    
    var onEdit: ((CalendarCollectionItem) -> ())?
    
    var customView: CalendarCollectionItemView {
        return self.view as! CalendarCollectionItemView
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customView.onDoubleClick = self.handleDoubleClick
        customView.onBeforeResize = self.handleBeforeResize
        customView.onResize = self.handleResize
        customView.onFinishResize = self.handleFinishResize
        
        let view = self.view as! CalendarCollectionItemView

        
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
            
            self.field.alpha = 1
            view.isDashed = false
            
            switch type {
            case .task:
                guard let color = Palette.decode(colorName: colorName) else { return }
                let color1 = color.addHue(0, saturation: -0.3, brightness: 0.2, alpha: -0.9)
                let borderColor = color.addHue(0, saturation: -0.3, brightness: 0.2, alpha: -0.2)
                
                let textColor = color.addHue(0, saturation: -0.2, brightness: -0.2, alpha: 0)
                
                view.background = color1
                view.border = borderColor
                
                self.field.textColor = textColor
                self.field.stringValue = self.event.value?.task?.title ?? ""
                
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
                        self.field.textColor = NSColor.white
                        self.field.stringValue = "Pomodoro"
                        self.field.alpha = 0.85
                    case .shortBreak, .longBreak:
                        let green = NSColor(hexString: "9BDDB6")!
                        view.background = green
                        view.border = green
                        self.field.textColor = NSColor.white
                        self.field.stringValue = "Break"
                        self.field.alpha = 0.85
                    }
                case .general:
                    guard let color = Palette.decode(colorName: colorName) else { return }
                    let color1 = color.addHue(0, saturation: -0.3, brightness: 0.2, alpha: -0.2)
                    view.background = color1
                    view.border = color1
                    self.field.textColor = color
                    self.field.stringValue = self.event.value?.timerEntry?.task?.title ?? ""
                }
                
                break
            }
        }
    }
    

    override var isSelected: Bool {
        didSet {
            if isSelected {
                customView.isHighlighted = true
            } else {
                customView.isHighlighted = false
            }
        }
    }
    
    override var highlightState: NSCollectionViewItemHighlightState {
        didSet {
            switch highlightState {
            case .forSelection:
                customView.isHighlighted = true
            case .forDeselection:
                customView.isHighlighted = false
            default:
                break
//                customView.isHighlighted = false
            }
        }
    }
    
    func handleDoubleClick() {
        onEdit?(self)
    }
    
    var initialDuration: TimeInterval = 0

    func handleBeforeResize() {
        initialDuration = event.value!.duration
    }
    
    func handleResize(delta: CGFloat) {
        let collectionView = self.view.superview as! NSCollectionView
        let layout = collectionView.collectionViewLayout as! CalendarCollectionLayout
        let durationDelta = layout.duration(pointValue: delta)
        
        let duration = initialDuration + durationDelta
        
        event.value!.duration = duration

        layout.invalidateLayout()
        
        let minutes = Int(round(duration / 60))
        
        self.field.stringValue = Formatting.format(estimate: minutes)
    }
    
    func handleFinishResize() {
        initialDuration = 0
        
        guard let event = self.event.value else { return }
        
        if let task = event.task {
            task.estimatedMinutes = Int64(round(event.duration / 60))
        } else if let entry = event.timerEntry,
            let start = entry.startedAt {
            
            entry.endedAt = start.addingTimeInterval(event.duration)
        }
    }
}
