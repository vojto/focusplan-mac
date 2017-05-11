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
    
    @IBOutlet weak var mainView: NSView!
    @IBOutlet weak var sidebarView: NSView!
    
    let selectedProject = MutableProperty<Project?>(nil)
    
    let projectsController = ProjectsViewController()
    
    var tasksObserver: TasksObserver!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Force tasks controller to load the view
        _ = tasksController.view
        
        let context = AppDelegate.viewContext
        
        // Creating the observer
        tasksObserver = TasksObserver(wantsPlannedOnly: false, in: context)
        tasksObserver.skipsArchived = true
        
        tasksObserver.sortedForProject.producer.startWithValues { tasks in
            if self.selectedProject.value == nil {
                return
            }
            
            self.tasksController.tasks = tasks
            self.tasksController.reloadData()
        }
        
        // Handling changing of project
        selectedProject.producer.startWithValues { project in
            self.tasksObserver.project = project
            self.tasksObserver.update()
            
            self.tasksController.heading = project?.name ?? ""
        }
        
        // Tasks controller actions
        tasksController.onCreate = {
            self.createTask()
        }
        
        // Setup the view
        mainView.include(tasksController.view)
        sidebarView.include(projectsController.view)
        
        // Handling selecting project in projects controller
        projectsController.onSelect = { item in
            if let project = item as? Project {
                self.selectedProject.value = project
            }
        }
        
    }
    
    func createTask() {
        guard let project = selectedProject.value else { return }
        
        let context = AppDelegate.viewContext
        let task = Task(entity: Task.entity(), insertInto: context)
        
        task.title = ""
        task.weight = tasksController.nextWeight
        task.project = project
        
        DispatchQueue.main.async {
            self.tasksController.edit(task: task)
        }
    }
}
