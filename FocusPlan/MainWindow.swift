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
    
    
    let projectsController = ProjectsViewController()
    
    let planController = PlanViewController()
    
    let backlogController = BacklogViewController()
    
    override func awakeFromNib() {

        secondaryView.include(projectsController.view)
        
        mainView.include(backlogController.view)
        
        mainView.include(planController.view)
        
        backlogController.view.isHidden = true
        planController.view.isHidden = true
    
    
        projectsController.onSelect = { item in
            self.showSection(forItem: item)
        }
    }
    
    func showSection(forItem item: Any?) {
        backlogController.view.isHidden = true
        planController.view.isHidden = true
        
        if let project = item as? Project {
            backlogController.selectedProject.value = project
            backlogController.view.isHidden = false
            
        } else if let planItem = item as? ProjectsViewController.PlanItem {
            planController.view.isHidden = false
            
            switch planItem.type {
            case .today:
                Swift.print("Gonna display plan controller!")
            default: break
            }
        }
    }
    
    
    @IBAction func createTask(_ sender: Any) {
//        tasksController.createTask(sender)
    }
}
