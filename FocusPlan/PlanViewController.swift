//
//  PlanViewController.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 28/04/2017.
//  Copyright © 2017 Median. All rights reserved.
//

import Cocoa
import NiceData

class PlanViewController: NSViewController {
    
    let tasksController = TasksViewController()
    var observer: ReactiveObserver<Task>!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tasksController.wantsHighlightPlanned = false
        tasksController.weightKeypath = #keyPath(Task.weightForPlan)
        tasksController.onCreate = { self.createTask() }
        
        observer = {
            let context = AppDelegate.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
            request.predicate = NSPredicate(format: "isPlanned = true")
            return ReactiveObserver<Task>(context: context, request: request)
        }()
        
        
        
        view.include(tasksController.view)
        
        observer.objects.producer.startWithValues { tasks in
            self.tasksController.tasks = tasks
            self.tasksController.heading = "Planned tasks"
            self.tasksController.reloadData()
        }
    }
    
    func createTask() {
        let context = AppDelegate.viewContext
        
        let project: Project? = context.findFirst()
        
        let task = Task(entity: Task.entity(), insertInto: context)
        task.project = project
        task.isPlanned = true
        
        DispatchQueue.main.async {
            self.tasksController.edit(task: task)
        }
        
    }
    
    
}
