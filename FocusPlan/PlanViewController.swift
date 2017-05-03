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
}

struct PlanConfig {
    var range: PlanRange
    var lanes: [PlanLane]
    var durationsOnly = false
    
    static var defaultConfig: PlanConfig {
        return PlanConfig(
            range: PlanRange(start: Date(), dayCount: 1),
            lanes: [.task, .pomodoro],
            durationsOnly: false
        )
    }
}

enum PlanLane {
    case project
    case task
    case pomodoro
}

class PlanViewController: NSViewController {
    
    let tasksController = TasksViewController()
    let calendarController = CalendarViewController()
    
    var config = PlanConfig.defaultConfig {
        didSet {
            calendarController.config = config
            updateCalendarWithLastValues()
        }
    }
    
    var tasksObserver: TasksObserver!
    var timerEntriesObserver: ReactiveObserver<TimerEntry>!
    
    var lastTasks = [Task]()
    var lastTimerEntries = [TimerEntry]()
    
    @IBOutlet var secondaryView: NSView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tasksController.wantsHighlightPlanned = false
        tasksController.weightKeypath = #keyPath(Task.weightForPlan)
        tasksController.onCreate = { self.createTask() }
        
        let context = AppDelegate.viewContext
        
        tasksObserver = TasksObserver(wantsPlannedOnly: true, in: context)
        let sortedTasks = tasksObserver.sortedTasksForPlan
        
        timerEntriesObserver = {
            // TODO: Filter by displayed time range
            // ... for now we're displaying all!
            let request: NSFetchRequest<NSFetchRequestResult> = TimerEntry.fetchRequest()
//            request.predicate = NSPredicate(format: "isPlanned = true")
            return ReactiveObserver<TimerEntry>(context: context, request: request)
        }()
        
        view.include(tasksController.view)
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
        
        let now = timer(interval: .seconds(5), on: QueueScheduler.main)
        
        now.startWithValues { _ in
            self.updateCalendarWithLastValues()
        }
    }
    
    func updateCalendarWithLastValues() {
        self.updateCalendar(tasks: lastTasks, timerEntries: lastTimerEntries)
    }
    
    func updateCalendar(tasks: [Task], timerEntries: [TimerEntry]) {
        // Update events in the calendar view
        let taskEvents = createEvents(fromTasks: tasks.filter({ !$0.isFinished }), timerEntries: timerEntries)

        let timerEvents = createTimerEvents(fromEntries: timerEntries)
        
        calendarController.events = timerEvents + taskEvents
        
        self.calendarController.reloadData()
    }
    
    /**
     Takes timer entries so it can calculate how much time was spent already
     on a task.
     */
    func createEvents(fromTasks tasks: [Task], timerEntries: [TimerEntry]) -> [CalendarEvent] {
        var events = [CalendarEvent]()
        
        var previous: CalendarEvent?
        
        for task in tasks {
            let startsAt: Date
            
            if let previous = previous {
                startsAt = previous.endsAt
            } else {
                startsAt = Date()
            }
            
            var duration = task.estimate

            // Adjust duration by time already spent on this task
            duration -= durationSpentToday(onTask: task, timerEntries: timerEntries)
            
            if duration < 0 {
                continue
            }
            
            let event = CalendarEvent(task: task, startsAt: startsAt, duration: duration)
            
            events.append(event)
            previous = event
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
            guard let startedAt = entry.startedAt else {
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
            
            let event = CalendarEvent(timerEntry: entry, startsAt: startedAt as Date, duration: duration)
            events.append(event)
        }
        
        return events
    }
    
    // MARK: - Creating tasks
    // -----------------------------------------------------------------------
    
    func createTask() {
        let context = AppDelegate.viewContext
        
        let project: Project? = context.findFirst()
        
        let task = Task(entity: Task.entity(), insertInto: context)
        task.project = project
        task.isPlanned = true
        task.weightForPlan = tasksController.nextWeight
        
        DispatchQueue.main.async {
            self.tasksController.edit(task: task)
        }
        
    }
    
    
}
