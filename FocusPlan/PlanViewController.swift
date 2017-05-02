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
    
    var tasksObserver: ReactiveObserver<Task>!
    
    var timerEntriesObserver: ReactiveObserver<TimerEntry>!
    
    @IBOutlet var secondaryView: NSView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tasksController.wantsHighlightPlanned = false
        tasksController.weightKeypath = #keyPath(Task.weightForPlan)
        tasksController.onCreate = { self.createTask() }
        
        let context = AppDelegate.viewContext
        
        tasksObserver = {
            let request: NSFetchRequest<NSFetchRequestResult> = Task.fetchRequest()
            request.predicate = NSPredicate(format: "isPlanned = true")
            return ReactiveObserver<Task>(context: context, request: request)
        }()
        
        timerEntriesObserver = {
            // TODO: Filter by displayed time range
            // ... for now we're displaying all!
            let request: NSFetchRequest<NSFetchRequestResult> = TimerEntry.fetchRequest()
//            request.predicate = NSPredicate(format: "isPlanned = true")
            return ReactiveObserver<TimerEntry>(context: context, request: request)
        }()
        
        view.include(tasksController.view)
        secondaryView.include(calendarController.view)
        
        let sortedTasks = tasksObserver.objects.producer.map { tasks in
            return tasks.sorted { task1, task2 in
                return task1.weightForPlan < task2.weightForPlan
            }
        }
        
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
            if entry.isRunning {
                continue
            }
            
            guard let startedAt = entry.startedAt, let duration = entry.duration else {
                continue
            }
            
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
