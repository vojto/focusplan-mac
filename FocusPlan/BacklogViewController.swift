//
//  BacklogViewController.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 28/04/2017.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit
import ReactiveSwift

class BacklogViewController: NSViewController {
    lazy var tasksController = {
        return TasksViewController(nibName: "TasksViewController", bundle: nil)!
    }()
    
    let selectedProject = MutableProperty<Project?>(nil)
    
    override func viewDidLoad() {
        tasksController.onCreate = {
            self.createTask()
        }
        
        view.include(tasksController.view)
        
        selectedProject.producer.startWithValues { project in
            self.tasksController.heading = project?.name ?? ""
            
            self.tasksController.reloadData()
        }
        
        let tasks = selectedProject.producer.pick({ $0.reactive.tasks.producer })
        tasks.startWithValues { tasks in
            if let tasks = tasks as? Set<Task> {
                self.tasksController.tasks = Array(tasks)
            } else {
                self.tasksController.tasks = []
            }
            
            self.tasksController.reloadData()
        }
    }
    
    func createTask() {
        guard let project = selectedProject.value else { return }
        
        let context = AppDelegate.viewContext
        let task = Task(entity: Task.entity(), insertInto: context)
        
        let nextWeight = (tasksController.tasks.map({ $0.weight }).max() ?? 0) + 1
        
        task.title = ""
        task.weight = nextWeight
        task.project = project
        
        DispatchQueue.main.async {
            self.tasksController.edit(task: task)
        }
    }
}
