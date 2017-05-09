//
//  PlanViewController.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 28/04/2017.
//  Copyright © 2017 Median. All rights reserved.
//

import Cocoa
import ReactiveSwift
import NiceData
import SwiftDate

struct PlanRange {
    var start: Date
    var dayCount: Int
    
    var lastDay: Date {
        return start + (dayCount - 1).days
    }
}

enum PlanStyle {
    case hybrid
    case durations
    case entries
}

struct PlanConfig {
    var range: PlanRange
    var lanes: [PlanLane]
    var detail: PlanDetail
    var style = PlanStyle.hybrid
    
    static var defaultConfig: PlanConfig {
        return PlanConfig(
            range: PlanRange(start: Date(), dayCount: 1),
            lanes: [.task, .pomodoro],
            detail: .daily,
            style: .hybrid
        )
    }
    
    public static func daily(date: Date) -> PlanConfig {
        let range = PlanRange(start: date.startOf(component: .day), dayCount: 1)
        
        return PlanConfig(
            range: range,
            lanes: [.task, .pomodoro],
            detail: .daily,
            style: .hybrid
        )
    }
    
    public static func weekly(date: Date) -> PlanConfig {
        let range = PlanRange(start: date.startOf(component: .weekOfYear), dayCount: 7)
        
        return PlanConfig(
            range: range,
            lanes: [.task],
            detail: .weekly,
            style: .durations
        )
    }
}

enum PlanLane {
    case project
    case task
    case pomodoro
}

enum PlanDetail {
    case daily
    case weekly
}

class PlanViewController: NSViewController, NSSplitViewDelegate {
    
    @IBOutlet var primaryView: NSView!
    @IBOutlet var secondaryView: NSView!
    
    @IBOutlet weak var titleField: NSTextField!
    @IBOutlet weak var detailControl: NSSegmentedControl!
    @IBOutlet weak var styleControl: NSSegmentedControl!
    
    
    let tasksController = TasksViewController()
    let calendarController = CalendarViewController()
    
    
    var config = PlanConfig.defaultConfig {
        didSet {
            Swift.print("✳️ Changed style to \(config.style)")
            
            updateObservers()
            updateLayout()
            calendarController.config = config
            updateCalendarWithLastValues()
        }
    }
    
    var tasksObserver: TasksObserver!
    var timerEntriesObserver: ReactiveObserver<TimerEntry>!
    
    var lastTasks = [Task]()
    var lastTimerEntries = [TimerEntry]()
    
    static var instance: PlanViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PlanViewController.instance = self
        
        tasksController.wantsHighlightPlanned = false
        tasksController.weightKeypath = #keyPath(Task.weightForPlan)
        tasksController.onCreate = { self.handleTasksCreate() }
        
        let context = AppDelegate.viewContext
        
        tasksObserver = TasksObserver(wantsPlannedOnly: true, in: context)
        let sortedTasks = tasksObserver.sortedTasksForPlan
        
        timerEntriesObserver = {
            let request: NSFetchRequest<NSFetchRequestResult> = TimerEntry.fetchRequest()
            return ReactiveObserver<TimerEntry>(context: context, request: request)
        }()
        
        updateObservers()
        
        primaryView.include(tasksController.view)
        secondaryView.include(calendarController.view)
        
        sortedTasks.startWithValues { tasks in
            self.tasksController.tasks = tasks
            self.tasksController.heading = "Planned tasks"
            self.tasksController.reloadData()
        }
        
        SignalProducer.combineLatest(
            sortedTasks,
            timerEntriesObserver.objects.producer
            ).startWithValues { tasks, timerEntries in
                self.lastTasks = tasks
                self.lastTimerEntries = timerEntries
                self.updateCalendar(tasks: tasks, timerEntries: timerEntries)
        }

        
        calendarController.onReorder = self.handleReorder
        calendarController.onCreate = self.handleCalendarCreate
        
        updateLayout()
        
//        let now = timer(interval: .seconds(5), on: QueueScheduler.main)
//        
//        now.startWithValues { _ in
//            self.updateCalendarWithLastValues()
//        }
    }
    
    func updateObservers() {
        let request: NSFetchRequest<NSFetchRequestResult> = TimerEntry.fetchRequest()
        
        let range = config.range
        let start = range.start.startOf(component: .day)
        let end = range.lastDay.endOf(component: .day)
        
        request.predicate = NSPredicate(format: "startedAt >= %@ and startedAt < %@", start as NSDate, end as NSDate)
        
        timerEntriesObserver.request = request
        
        tasksObserver.range = (start, end)
    }
    
    func updateLayout() {
        switch config.detail {
        case .daily:
            primaryView.isHidden = false
            detailControl.selectedSegment = 0
            styleControl.isHidden = true
        case .weekly:
            primaryView.isHidden = true
            detailControl.selectedSegment = 1
            styleControl.isHidden = false
        }
        
        switch config.style {
        case .hybrid, .entries:
            styleControl.selectedSegment = 1
        case .durations:
            styleControl.selectedSegment = 0
        }
        
        // Update the title too while we're at it
        let date = config.range.start
        var title = ""
        
        switch config.detail {
        case .daily:
            if date.isToday {
                title = "Today"
            } else if date.isTomorrow {
                title = "Tomorrow"
            } else if date.isYesterday {
                title = "Yesterday"
            } else {
                title = date.string(custom: "E, MMM d yyyy")
            }
            
            
        case .weekly:
            let now = Date()
            let thisWeek = (now.startOf(component: .weekOfYear), now.endOf(component: .weekOfYear))
            let nextWeek = ((now + 1.week).startOf(component: .weekOfYear), (now + 1.week).endOf(component: .weekOfYear))
            let previousWeek = ((now - 1.week).startOf(component: .weekOfYear), (now - 1.week).endOf(component: .weekOfYear))
            
            if date >= thisWeek.0 && date <= thisWeek.1 {
                title = "This week"
            } else if date >= previousWeek.0 && date <= previousWeek.1 {
                title = "Previous week"
            } else if date >= nextWeek.0 && date <= nextWeek.1 {
                title = "Next week"
            } else {
                title = "Week of " + date.startOf(component: .weekOfYear).string(custom: "MMM d, YYYY")
            }
        }
        
        titleField.stringValue = title
    }
    
    @IBAction func changeDetail(_ sender: Any) {
        switch detailControl.selectedSegment {
        case 0:
            self.config = PlanConfig.daily(date: config.range.start)
        case 1:
            self.config = PlanConfig.weekly(date: config.range.start)
        default: break
        }
    }
    
    @IBAction func changeStyle(_ sender: Any) {
        switch styleControl.selectedSegment {
        case 0:
            self.config.style = .durations
        case 1:
            self.config.style = .entries
        default: break
        }
    }

    
    
    func splitView(_ splitView: NSSplitView, shouldHideDividerAt dividerIndex: Int) -> Bool {
        switch config.detail {
        case .daily:
            return false
        case .weekly:
            return true
        }
    }
    
    func updateCalendarWithLastValues() {
        self.updateCalendar(tasks: lastTasks, timerEntries: lastTimerEntries)
    }
    
    func updateCalendar(tasks: [Task], timerEntries: [TimerEntry]) {
        
        // Update events in the calendar view
        let taskEvents = createEvents(fromTasks: tasks, timerEntries: timerEntries)

        let timerEvents = createTimerEvents(fromEntries: timerEntries)
        
        let events: [CalendarEvent]
        
        Swift.print("👙 Updating calendar with \(timerEvents.count) timer events")
        
        switch config.style {
        case .entries:
            events = timerEvents
        default:
            events = timerEvents + taskEvents
        }
    
        
        calendarController.events.reset(sectionsCount: config.range.dayCount)
        
        for (_, event) in events.enumerated() {
            // For now, stick them all in one section
            
            let rangeStart = config.range.start.startOf(component: .day)
            
            guard let date = event.date else { continue }
            
            let interval = date.timeIntervalSince(rangeStart)
            
            let dayIndex = Int(floor(interval / (60 * 60 * 24)))
            
            if dayIndex < 0 {
                continue
            }
            
            calendarController.events.append(event: event, section: dayIndex)
        }
        
        self.calendarController.reloadData()
    }
    
    /**
     Takes timer entries so it can calculate how much time was spent already
     on a task.
     */
    func createEvents(fromTasks tasks: [Task], timerEntries: [TimerEntry]) -> [CalendarEvent] {
        var events = [CalendarEvent]()
        
        let tasksByDays = tasks.group { ($0.plannedFor! as Date).string(format: .custom("yyyyMMdd")) }
        
        var tasksAdded = 0

        for (_, tasks) in tasksByDays {
            for (_, task) in tasks.enumerated() {
                var duration = task.estimate
                
                // Adjust duration by time already spent on this task
                duration -= durationSpentToday(onTask: task, timerEntries: timerEntries)
                
                let event = CalendarEvent(task: task, startsAt: nil, duration: duration)
                
                if duration < 0 || task.isFinished {
                    event.isHidden = true
                    event.duration = 0
                }
                
                tasksAdded += 1
                events.append(event)
            }
        }
        
        return events
    }
    
    func durationSpentToday(onTask task: Task, timerEntries: [TimerEntry]) -> TimeInterval {
        let taskEntries = timerEntries.filter { $0.task == task }
        let entriesToday = taskEntries.filter { ($0.startedAt! as Date).isToday }
        
        var total: TimeInterval = 0
        
        for entry in entriesToday {
            if let duration = entry.duration {
                total += duration
            } else if let startedAt = entry.startedAt, entry.endedAt == nil {
                let durationSoFar = Date().timeIntervalSince(startedAt as Date)
                total += durationSoFar
            }
        }
        
        return total
    }
    
    func createTimerEvents(fromEntries entries: [TimerEntry]) -> [CalendarEvent] {
        var events = [CalendarEvent]()
        
        for entry in entries {
            guard var startedAt = entry.startedAt else {
                assertionFailure()
                continue
            }
            
            let endedAt: Date
            
            if let entryEndedAt = entry.endedAt {
                endedAt = entryEndedAt as Date
            } else {
                endedAt = Date()
            }
            
            let duration = endedAt.timeIntervalSince(startedAt as Date)
            
            let startTime = config.style != .durations ? (startedAt as Date).timeIntervalSinceStartOfDay : nil
            
            let event = CalendarEvent(timerEntry: entry, startsAt: startTime, duration: duration)
            events.append(event)
        }
        
        return events
    }
    
    // MARK: - Creating tasks
    // -----------------------------------------------------------------------
    
    func handleCalendarCreate() {
        let task = createTask()
        
        DispatchQueue.main.async {
            self.calendarController.edit(task: task)
        }
    }
    
    func handleTasksCreate() {
        let task = createTask()
        
        DispatchQueue.main.async {
            self.tasksController.edit(task: task)
        }
    }
    
    func createTaskFromWindow() {
        switch config.detail {
        case .daily:
            handleTasksCreate()
        case .weekly:
            handleCalendarCreate()
        }
    }
    
    @discardableResult
    func createTask() -> Task {
        let context = AppDelegate.viewContext
        
        let project: Project? = context.findFirst()
        
        let task = Task(entity: Task.entity(), insertInto: context)
        task.project = project
        task.plannedFor = Date() as NSDate
        task.weightForPlan = tasksController.nextWeight

        return task
    }
    
    // MARK: - Reordering tasks
    // -----------------------------------------------------------------------
    
    func handleReorder() {
//        Swift.print("Handling reorder...")
        
        for (i, events) in calendarController.events.sections.enumerated() {
            var weight = 0
            
            Swift.print("SAving order for \(events.count) events in section \(i)")
            
            for event in events {
                if let task = event.task {
                    task.weightForPlan = Int64(weight)
                    Swift.print("Set weight \(weight) for task \(task.title)")
                    weight += 1
                    
                    task.plannedFor = (config.range.start + i.days) as NSDate
                }
                
            }
        }
    }
    
    // MARK: - Changing the config
    // -----------------------------------------------------------------------
    
    @IBAction func previousUnit(_ sender: Any) {
        updateRange(change: -1)
    }
    
    @IBAction func nextUnit(_ sender: Any) {
        updateRange(change: 1)
    }
    
    func updateRange(change units: Int) {
        let date: Date
        let config = self.config
        
        switch config.detail {
        case .daily:
            date = config.range.start + units.days
        case .weekly:
            date = config.range.start + units.weeks
        }
        
        self.config.range.start = date
    }
    
}
