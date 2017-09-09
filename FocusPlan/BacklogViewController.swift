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
import Cartography

class BacklogViewController: NSViewController {
    lazy var tasksController = {
        return TasksViewController(nibName: "TasksViewController", bundle: nil)!
    }()
    
    @IBOutlet weak var mainView: NSView!
    
    let selectedProject = MutableProperty<Project?>(nil)
    
    var tasksObserver: TasksObserver!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Force tasks controller to load the view
        _ = tasksController.view
        tasksController.wantsProjectColumn = false
        tasksController.wantsPlanColumn = true
        
        let context = AppDelegate.viewContext
        
        // Creating the observer
        tasksObserver = TasksObserver(wantsPlannedOnly: false, wantsUnfinishedOnly: false, in: context, includeProperties: false)
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

        tasksController.headerView.producer.skipRepeats({ $0 === $1 }).startWithValues { view in
            if let view = view {
                self.setupColorPicker(inView: view)
            }
        }
        
        
        // Setup the view
        mainView.include(tasksController.view)
    }

    let picker = ProjectColorPicker()

    func setupColorPicker(inView view: TasksHeaderTableCellView) {

        view.addSubview(picker)

        picker.colors = Palette.colors.map { NSColor(hexString: $0.area0)! }
        picker.selectedColor = picker.colors.first
        picker.wantsAuto = false

        picker.onChange = { nsColor in
            Swift.print("Picker changed color!")

            guard let colorName = Palette.encode(color: nsColor) else { assertionFailure(); return }
            self.selectedProject.value?.color = colorName

            Swift.print("Updating projects [\(self.selectedProject.value)] color to \(colorName)")
        }

        let color = selectedProject.producer.pick { $0.reactive.color }
        color.startWithValues { colorName in
            guard let nsColor = Palette.decode(colorName: colorName) else { return }
            self.picker.selectedColor = nsColor
        }

        constrain(picker, view.titleLabel) { picker, title in
            picker.width == 20.0
            picker.height == 20.0
            picker.left == title.right + 8.0
            picker.centerY == title.centerY
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
