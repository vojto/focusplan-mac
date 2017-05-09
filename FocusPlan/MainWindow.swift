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
import SwiftDate

class MainWindow: NSWindow, NSToolbarDelegate {
    @IBOutlet weak var secondaryView: NSView!
    @IBOutlet weak var mainView: NSView!
    
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
        
        backlogController.view.isHidden = true
//        planController.view.isHidden = true
//        mainView2.isHidden = true
    
        projectsController.onSelect = { item in
            self.showSection(forItem: item)
        }
        
        TimerState.instance.selectedTask <~ planController.tasksController.selectedTasks.producer.map { $0.first }
    }
    
    func showSection(forItem item: Any?) {
        if let project = item as? Project {
            showProject(project)
        } else if let planItem = item as? ProjectsViewController.PlanItem {
            switch planItem.type {
            case .today:
                showPlan(detail: .daily, date: Date())
            case .thisWeek:
                showPlan(detail: .weekly, date: Date())
            }
        }
    }
    
    @IBAction func showDailyPlan(_ sender: Any) {
        showPlan(detail: .daily, date: Date())
    }
    
    @IBAction func showWeeklyPlan(_ sender: Any) {
        showPlan(detail: .weekly, date: Date())
    }
    
    @IBAction func nextUnit(_ sender: Any) {
        updateRange(change: 1)
    }
    
    @IBAction func previousUnit(_ sender: Any) {
        updateRange(change: -1)
    }
    
    func updateRange(change units: Int) {
        let date: Date
        let config = planController.config

        switch config.detail {
        case .daily:
            date = config.range.start + units.days
        case .weekly:
            date = config.range.start + units.weeks
        }
        
        planController.config.range.start = date
    }
    
    func showProject(_ project: Project) {
        planController.view.isHidden = true
        mainView.isHidden = false
        backlogController.selectedProject.value = project
        backlogController.view.isHidden = false
    }
    
    func showPlan(detail: PlanDetail, date: Date) {
        backlogController.view.isHidden = true
        mainView.isHidden = false
        planController.view.isHidden = false
        
        switch detail {
        case .daily:
            planController.config = PlanConfig.daily(date: Date())
            
        case .weekly:
            planController.config = PlanConfig.weekly(date: Date())
            
            planController.calendarController.collectionView.scroll(NSPoint(x: 0, y: 0))
        }
    }
    
    
    @IBAction func createTask(_ sender: Any) {
        if !backlogController.view.isHidden {
            backlogController.createTask()
        } else if !planController.view.isHidden {
            planController.createTaskFromWindow()
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
