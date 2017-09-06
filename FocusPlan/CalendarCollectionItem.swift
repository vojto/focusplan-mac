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
    let field = NSTextField(labelWithString: "")
    let configProjectField = ProjectField()
    let configEstimateField = NiceField()
    var customView: CalendarCollectionItemView { return self.view as! CalendarCollectionItemView }

    // Constraints
    var leftConstraint: NSLayoutConstraint?
    var rightConstraint: NSLayoutConstraint?

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

        connectProducers()

        setup()

        applyStyle()


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

                self.setPresentedTimerEntry(entry, colorName: colorName)

            }
        }
    }

    func connectProducers() {
        self.project = self.task.producer.pick { $0.reactive.project.producer }

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
    }

    // MARK: - Setting up the views
    // ------------------------------------------------------------------------

    func setup() {
        let fieldRow = setupFieldRow()
        let configRow = setupConfigRow()

        let spacer = NSView()
        spacer.setContentHuggingPriority(1, for: .vertical)

        let stack = NSStackView(views: [fieldRow, spacer, configRow])
        stack.setClippingResistancePriority(250, for: .vertical)
        stack.orientation = .vertical
        stack.alignment = .leading

        stack.setVisibilityPriority(1, for: spacer)
        stack.setVisibilityPriority(999, for: fieldRow)
        stack.setVisibilityPriority(500, for: configRow)

        customView.addSubview(stack)
        constrain(stack) { stack in
            self.leftConstraint = (stack.left == stack.superview!.left + 6.0)
            self.rightConstraint = (stack.right == stack.superview!.right - 6.0)
            stack.top == stack.superview!.top + 8.0
            stack.bottom == stack.superview!.bottom - 8.0 ~ 100
        }

        setupCustomView()
    }

    func setupFieldRow() -> NSView {
        field.setContentHuggingPriority(1, for: .vertical)
        field.lineBreakMode = .byWordWrapping

        let view = NSView()
        view.addSubview(field)

        constrain(field) { field in
            field.left == field.superview!.left + 6.0
            field.right == field.superview!.right - 6.0
            field.top == field.superview!.top
            field.bottom == field.superview!.bottom
        }

        return view
    }

    func setupConfigRow() -> NSView {
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
        let row = NSStackView()
        row.orientation = .horizontal
        row.setViews([configProjectField, configEstimateField], in: .leading)
        row.setClippingResistancePriority(100, for: .horizontal)
        row.setVisibilityPriority(1, for: configProjectField)
        row.setVisibilityPriority(1000, for: configEstimateField)

        return row
    }

    func setupCustomView() {
        customView.onDoubleClick = self.handleDoubleClick
        customView.onBeforeResize = self.handleBeforeResize
        customView.onResize = self.handleResize
        customView.onFinishResize = self.handleFinishResize
    }

    func setPresentedTimerEntry(_ entry: TimerEntry, colorName: String?) {
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



    func styleConfigField(field: NiceField) {
        field.textColor = NSColor.white
        field.borderColor = NSColor.white.alpha(0.2)
        field.editingBackgroundColor = NSColor.black.alpha(0.1)
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
            leftConstraint?.constant = 6.0
            rightConstraint?.constant = 6.0
            configProjectField.isHidden = false

        case .small:
            field.font = NSFont.systemFont(ofSize: 12)
            leftConstraint?.constant = 4.0
            rightConstraint?.constant = 4.0
            configProjectField.isHidden = true

        }

        customView.style.value = style
    }
}
