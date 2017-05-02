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

class PlanViewController: NSViewController {
    
    let tasksController = TasksViewController()
    let calendarController = CalendarViewController()
    
    var tasksObserver: TasksObserver!
    
    var timerEntriesObserver: ReactiveObserver<TimerEntry>!
    
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
                self.updateCalendar(tasks: tasks, timerEntries: timerEntries)
        }
    }
    
    func updateCalendar(tasks: [Task], timerEntries: [TimerEntry]) {
        
        
        // Update events in the calendar view
        let taskEvents = createEvents(fromTasks: tasks.filter({ !$0.isFinished }))

        let timerEvents = createTimerEvents(fromEntries: timerEntries)
        
        calendarController.events = taskEvents + timerEvents
        
        self.calendarController.reloadData()
    }
    
    func createEvents(fromTasks tasks: [Task]) -> [CalendarEvent] {
        var events = [CalendarEvent]()
        
        var previous: CalendarEvent?
        
        for task in tasks {
            let startsAt: Date
            
            if let previous = previous {
                startsAt = previous.endsAt
            } else {
                startsAt = Date()
            }
            
            let event = CalendarEvent(task: task, startsAt: startsAt, duration: task.estimate)
            
            events.append(event)
            previous = event
        }
        
        return events
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
