//
//  MainWindow.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 4/25/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Cocoa
import NiceKit

class MainWindow: NSWindow {
    @IBOutlet weak var secondaryView: NSView!
    @IBOutlet weak var mainView: NSView!
    
    lazy var projectsController = {
        return ProjectsViewController(nibName: "ProjectsViewController", bundle: nil)!
    }()
    
    lazy var tasksController = {
        return TasksViewController(nibName: "TasksViewController", bundle: nil)!
    }()
    
    
    override func awakeFromNib() {

        secondaryView.include(projectsController.view)
        
        mainView.include(tasksController.view)
        
        projectsController.onSelect = { project in
            self.tasksController.project.value = project
        }
        
    }
}
