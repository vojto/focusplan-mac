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

class MainWindow: NSWindow, NSToolbarDelegate {
    @IBOutlet weak var secondaryView: NSView!
    @IBOutlet weak var mainView: NSView!
    @IBOutlet weak var mainView2: NSView!
    
    let projectsController = ProjectsViewController()
    
    let planController = PlanViewController()
    
    let backlogController = BacklogViewController()
    
    @IBOutlet weak var timerController: TimerViewController!
    
    let myDelegate = MainWindowDelegate()
    
    
    override func awakeFromNib() {
        
        self.delegate = myDelegate

        secondaryView.include(projectsController.view)
        
        mainView.include(backlogController.view)
        
        mainView.include(planController.view)
        mainView2.include(planController.secondaryView)
        
        backlogController.view.isHidden = true
//        planController.view.isHidden = true
//        mainView2.isHidden = true
    
        projectsController.onSelect = { item in
            self.showSection(forItem: item)
        }
        
        TimerState.instance.selectedTask <~ planController.tasksController.selectedTasks.producer.map { $0.first }
    }
    
    func showSection(forItem item: Any?) {
        backlogController.view.isHidden = true
        planController.view.isHidden = true
        mainView.isHidden = false
        mainView2.isHidden = true
        
        if let project = item as? Project {
            backlogController.selectedProject.value = project
            backlogController.view.isHidden = false
            
        } else if let planItem = item as? ProjectsViewController.PlanItem {
            planController.view.isHidden = false
            mainView2.isHidden = false
            
            switch planItem.type {
            case .today:
                planController.config = PlanConfig(
                    range: PlanRange(start: Date(), dayCount: 1),
                    lanes: [.task, .pomodoro],
                    durationsOnly: false
                )
                planController.calendarController.reloadData()
                
            case .thisWeek:
                mainView.isHidden = true
                
                planController.config = PlanConfig(
                    range: PlanRange(start: Date().startOf(component: .weekOfYear), dayCount: 7),
                    lanes: [.task],
                    durationsOnly: true
                )
                
                planController.calendarController.reloadData()
                planController.calendarController.collectionView.scroll(NSPoint(x: 0, y: 0))
            }
        }
    }
    
    
    @IBAction func createTask(_ sender: Any) {
        if !backlogController.view.isHidden {
            backlogController.createTask()
        } else if !planController.view.isHidden {
            planController.createTask()
        }
    }
    
    @IBOutlet weak var timerView: NSView!
    
    let kTimerItem = "Timer"
    let kAddButton = "AddButton"
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [String] {
        return [
            NSToolbarFlexibleSpaceItemIdentifier,
            kTimerItem,
            kAddButton
        ]
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [String] {
        return [NSToolbarFlexibleSpaceItemIdentifier, kTimerItem, NSToolbarFlexibleSpaceItemIdentifier]
    }
    
    class BlueView: NSView {
        override func draw(_ dirtyRect: NSRect) {
            NSColor.blue.set()
            NSRectFill(bounds)
        }
    }
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier id: String, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        
        let item = NSToolbarItem(itemIdentifier: id)
        
        switch id {
        case kTimerItem:
            item.label = "Timer"
            item.view = timerView
            
            return item
        case kAddButton:
            item.label = "Add"
            let button = NSButton(title: "Awesome!", target: self, action: nil)
            button.setContentHuggingPriority(125, for: .vertical)
            item.view = button
            
            return item
        default:
            return nil
        }
    }
    
    
}
