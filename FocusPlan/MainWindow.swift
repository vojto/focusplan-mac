//
//  MainWindow.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 4/25/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Cocoa
import NiceKit
import ReactiveSwift

class MainWindow: NSWindow {
    @IBOutlet weak var secondaryView: NSView!
    @IBOutlet weak var mainView: NSView!
    
    lazy var projectsController = {
        return ProjectsViewController(nibName: "ProjectsViewController", bundle: nil)!
    }()
    
    let backlogController = BacklogViewController()
    
    override func awakeFromNib() {

        secondaryView.include(projectsController.view)
        
        mainView.include(backlogController.view)
        
        projectsController.onSelect = { project in
            self.backlogController.selectedProject.value = project
        }
    }
    
    
    @IBAction func createTask(_ sender: Any) {
//        tasksController.createTask(sender)
    }
}
