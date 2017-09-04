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
import Cartography
import NiceKit

class CalendarCollectionItem: NSCollectionViewItem {

    // Properties
    var style = CalendarCollectionItemStyle.regular { didSet { applyStyle() } }
    override var isSelected: Bool { didSet { applySelected() } }
    override var highlightState: NSCollectionViewItemHighlightState { didSet { applyHighlightState() } }

    // Models
    let event = MutableProperty<CalendarEvent?>(nil)
    var task = MutableProperty<Task?>(nil)
    var project: SignalProducer<Project?, NoError>!

    // Views
    @IBOutlet weak var field: NSTextField!
    var customView: CalendarCollectionItemView { return self.view as! CalendarCollectionItemView }
    

    // Callbacks
    var onEdit: ((CalendarCollectionItem) -> ())?


    // MARK: - Lifecycle
    // -------------------------------------------------------------------------

    override func prepareForReuse() {
        super.prepareForReuse()

        customView.timerView.prepareForReuse()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        applyStyle()
        
        customView.onDoubleClick = self.handleDoubleClick
        customView.onBeforeResize = self.handleBeforeResize
        customView.onResize = self.handleResize
        customView.onFinishResize = self.handleFinishResize
        
        self.task <~ event.producer.pick { event -> SignalProducer<Task?, NoError> in
            switch event.type {
            case .project:
                return SignalProducer(value: nil)
            case .task:
                return SignalProducer(value: event.task!)
            case .timerEntry:
                return event.timerEntry!.reactive.task
            }
        }

        customView.timerView.task <~ self.task

        self.project = self.task.producer.pick { $0.reactive.project.producer }

        setupConfigRow()
        
        let projectColor = project.pick { $0.reactive.color.producer }
        
        SignalProducer.combineLatest(event.producer, projectColor.producer).startWithValues { event, colorName in
            guard let event = event else { return }
            
            self.field.alpha = 1
            self.customView.isDashed = false

            self.customView.timerView.existingDuration.value = event.spentDuration

            self.customView.backgroundProgress = 0
            
            switch event.type {
            case .project:
                let colorName = event.project?.color
                guard let color = Palette.decode(colorName: colorName) else { return }
                let color1 = color.addHue(0, saturation: -0.3, brightness: 0.2, alpha: -0.9)
                self.customView.background = color1
                self.customView.border = NSColor.clear
                self.field.stringValue = ""
            case .task:
                let color = Palette.decode(colorName: colorName) ?? Palette.standard

                self.customView.background = color

                self.field.textColor = NSColor.white
                self.field.stringValue = self.event.value?.task?.title ?? ""

                break
            case .timerEntry:
                guard let entry = self.event.value?.timerEntry else { return }

                self.setTimerEntry(entry, colorName: colorName)

            }
        }
    }

    func setTimerEntry(_ entry: TimerEntry, colorName: String?) {
        guard let lane = LaneId(rawValue: entry.lane ?? "") else { return }

        switch lane {
        case .pomodoro:
            guard let type = PomodoroType(rawValue: entry.type ?? "") else { return }

            switch type {
            case .pomodoro:
                let red = NSColor(hexString: "FE9097")!
                self.customView.background = red
                self.customView.border = red
                self.field.textColor = NSColor.white
                self.field.stringValue = "Pomodoro"
                self.field.alpha = 0.85
            case .shortBreak, .longBreak:
                let green = NSColor(hexString: "9BDDB6")!
                self.customView.background = green
                self.customView.border = green
                self.field.textColor = NSColor.white
                self.field.stringValue = "Break"
                self.field.alpha = 0.85
            }
        case .general:
            self.field.stringValue = self.event.value?.timerEntry?.task?.title ?? "(no task)"

            if let color = Palette.decode(colorName: colorName) {
                let color1 = color.addHue(0, saturation: -0.3, brightness: 0.2, alpha: -0.2)
                self.customView.background = color1
                self.customView.border = color1
                self.field.textColor = color
            } else {
                self.customView.background = NSColor(hexString: "E0E7F0")!
                self.customView.border = NSColor(hexString: "97A9BE")!
                self.field.textColor = NSColor(hexString: "69798B")
            }
        }
    }

    
    func handleDoubleClick() {
        onEdit?(self)
    }

    // MARK: - Applying properties
    // -----------------------------------------------------------------------

    func applySelected() {
        if isSelected {
            customView.isHighlighted = true
        } else {
            customView.isHighlighted = false
        }
    }

    func applyHighlightState() {
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

    func applyStyle() {

        switch style {
        case .regular:
            field.font = NSFont.systemFont(ofSize: 13)
        case .small:
            field.font = NSFont.systemFont(ofSize: 12)
        }

        customView.style = style
    }

    // MARK: - Resizing
    // ------------------------------------------------------------------------
    
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
            event.value!.plannedDuration = initialDuration - durationDelta
        case .bottom:
            let duration = initialDuration + durationDelta
            let roundingInterval = Double(5 * 60) // 5 minutes

            let intervalsCount = duration / roundingInterval

            var durationRounded = round(intervalsCount) * roundingInterval

            let minIntervalCount = 6
            let minDuration = roundingInterval * Double(minIntervalCount)

            if durationRounded < minDuration {
                durationRounded = minDuration
            }

            event.value!.plannedDuration = durationRounded
        }

        layout.invalidateLayout()
        
        let minutes = Int(round(event.value!.duration / 60))
        let formattedMinutes = Formatting.format(estimate: minutes)
        
        switch event.value!.type {
        case .project:
            break
        case .task:
            configEstimateField.stringValue = formattedMinutes

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

    // MARK: - Config row (project and estimate)
    // ------------------------------------------------------------------------

    let configProjectField = ProjectField()
    let configEstimateField = NiceField()

    func setupConfigRow() {
        return

        let row = NSStackView()

        view.addSubview(row)

        // Layout the row
        constrain(row) { row in
            row.left == row.superview!.left + 6
            row.right == row.superview!.right - 8
            row.bottom == row.superview!.bottom - 6
//            row.height == 32
        }

        // Style the fields
        styleConfigField(field: configProjectField)
        styleConfigField(field: configEstimateField)

        // Bind the project field
        project.producer.startWithValues { project in
            self.configProjectField.stringValue = project?.name ?? "None"
        }

        configProjectField.onSelect = { selection in
            self.task.value?.setProjectFromSelection(selection)
        }

        // Bind estimate
        let estimate = task.producer.pick { $0.reactive.estimatedMinutesFormatted }
        estimate.producer.startWithValues { value in
            self.configEstimateField.stringValue = value ?? ""
        }

        configEstimateField.onChange = { value in
            self.task.value?.setEstimate(fromString: value)
        }

        // Set up views in the row
        row.orientation = .horizontal
        row.setViews([configProjectField, configEstimateField], in: .leading)
    }

    func styleConfigField(field: NiceField) {
        field.textColor = NSColor.white
        field.borderColor = NSColor.white.alpha(0.2)
        field.editingBackgroundColor = NSColor.black.alpha(0.1)
    }
}
