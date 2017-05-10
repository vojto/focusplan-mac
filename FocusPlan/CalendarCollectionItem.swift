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
        
        let task = event.producer.pick { event -> SignalProducer<Task?, NoError> in
            switch event.type {
            case .project:
                return SignalProducer(value: nil)
            case .task:
                return SignalProducer(value: event.task!)
            case .timerEntry:
                return event.timerEntry!.reactive.task
            }
        }
        
        let project = task.pick { $0.reactive.project.producer }
        let projectColor = project.pick { $0.reactive.color.producer }
        
        SignalProducer.combineLatest(event.producer, projectColor.producer).startWithValues { event, colorName in
            guard let event = event else { return }
            
            self.field.alpha = 1
            view.isDashed = false
            
            view.backgroundProgress = event.spentDuration / event.duration
            
            switch event.type {
            case .project:
                let colorName = event.project?.color
                guard let color = Palette.decode(colorName: colorName) else { return }
                let color1 = color.addHue(0, saturation: -0.3, brightness: 0.2, alpha: -0.9)
                view.background = color1
                view.border = NSColor.clear
                self.field.stringValue = ""
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
                    self.field.stringValue = self.event.value?.timerEntry?.task?.title ?? "(no task)"
                    
                    if let color = Palette.decode(colorName: colorName) {
                        let color1 = color.addHue(0, saturation: -0.3, brightness: 0.2, alpha: -0.2)
                        view.background = color1
                        view.border = color1
                        self.field.textColor = color
                    } else {
                        view.background = NSColor(hexString: "E0E7F0")!
                        view.border = NSColor(hexString: "97A9BE")!
                        self.field.textColor = NSColor(hexString: "69798B")
                    }
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
    var initialStartTime: TimeInterval = 0

    func handleBeforeResize() {
        let collectionView = self.view.superview as! NSCollectionView
        let layout = collectionView.collectionViewLayout as! CalendarCollectionLayout
        
        initialDuration = event.value!.duration
        
        let indexPath = collectionView.indexPath(for: self)!
        initialStartTime = layout.startTime(forEventAt: indexPath)
    }
    
    func handleResize(delta: CGFloat, handle: CalendarCollectionItemView.HandleType) {
        let collectionView = self.view.superview as! NSCollectionView
        let layout = collectionView.collectionViewLayout as! CalendarCollectionLayout
        let durationDelta = layout.duration(pointValue: delta)
        
        switch handle {
        case .top:
            event.value!.startsAt = initialStartTime + durationDelta
            event.value!.duration = initialDuration - durationDelta
        case .bottom:
            event.value!.duration = initialDuration + durationDelta
        }
        

        layout.invalidateLayout()
        
        let minutes = Int(round(event.value!.duration / 60))
        let formattedMinutes = Formatting.format(estimate: minutes)
        
        switch event.value!.type {
        case .project:
            break
        case .task:
            field.stringValue = formattedMinutes
        case .timerEntry:
            if let event = self.event.value,
                let from = event.startDate?.string(custom: "h:mm"),
                let to = event.endDate?.string(custom: "h:mm") {
                field.stringValue = "\(from) - \(to) (\(formattedMinutes))"
            }
        }
        
        
    }
    
    func handleFinishResize(handle: CalendarCollectionItemView.HandleType) {
        initialDuration = 0
        
        guard let event = self.event.value else { return }
        
        if let task = event.task {
            task.estimatedMinutes = Int64(round(event.duration / 60))
        } else if let entry = event.timerEntry,
            let start = (entry.startedAt as Date?) {
            
            let dayStart = start.startOf(component: .day)
            entry.startedAt = dayStart.addingTimeInterval(event.startsAt!) as NSDate
            entry.endedAt = entry.startedAt!.addingTimeInterval(event.duration)
            
//            entry.endedAt = start.addingTimeInterval(event.duration)
        }
    }
}
