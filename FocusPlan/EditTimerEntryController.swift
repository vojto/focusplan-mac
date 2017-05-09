//
//  EditTimerEntryController.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/8/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Cocoa
import AppKit
import ReactiveSwift
import NiceReactive

class EditTimerEntryController: NSViewController {
    
    let entry = MutableProperty<TimerEntry?>(nil)
    
    @IBOutlet weak var startField: NSTextField!
    @IBOutlet weak var endField: NSTextField!
    @IBOutlet weak var durationField: NSTextField!
    @IBOutlet weak var taskPopup: NSPopUpButton!
    var taskSelect: ReactiveSelect<Task>!
    
    
    var onFinishEditing: (() -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let formatDate = { (date: Date?) -> String in
            return date?.string(custom: "h:mm a") ?? ""
        }
        
        startField.reactive.stringValue <~ entry.producer.pick({
            $0.reactive.startedAt.producer
        }).map(formatDate)
        
        endField.reactive.stringValue <~ entry.producer.pick({
            $0.reactive.endedAt.producer
        }).map(formatDate)
        
        durationField.reactive.stringValue <~ entry.producer.pick({
            $0.reactive.duration.producer
        }).map({
            Int(round(($0 ?? 0) / 60))
        }).map(Formatting.format(estimate:))
        
        setupTaskSelect()
    }
    
    func setupTaskSelect() {
        guard let controller = PlanViewController.instance else { return }
        
        taskSelect = ReactiveSelect(button: taskPopup, allowsNone: true)
        taskSelect.label = { $0.title ?? "" }
        
        let selectedTask = entry.producer.pick({ $0.reactive.task.producer })
        
        let availableTasks = SignalProducer.combineLatest(
            controller.tasksObserver.sortedTasksForPlan,
            selectedTask
        ).map { tasks, selectedTask -> [Task] in
            guard let task = selectedTask else { return tasks }
            
            if tasks.contains(task) {
               return tasks
            } else {
                return [task] + tasks
            }
        }
        
        taskSelect.rac_values <~ availableTasks
        
        taskSelect.rac_selectedValue <~ entry.producer.pick({ $0.reactive.task.producer })
        
        taskSelect.onChange = { task in
            self.entry.value?.task = task
            self.entry.value?.project = task?.project
        }
    }
    
}
