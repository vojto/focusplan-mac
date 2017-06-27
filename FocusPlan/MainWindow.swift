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
    
    let planController = PlanViewController()
    
    let backlogController = BacklogViewController()
    
    @IBOutlet weak var timerController: TimerViewController!
    
    let myDelegate = MainWindowDelegate()
    
    
    override func awakeFromNib() {
        
        self.delegate = myDelegate
        
        self.titlebarAppearsTransparent = true
        self.titleVisibility = .hidden

        mainView.include(backlogController.view)
        
        mainView.include(planController.view)
        
        backlogController.view.isHidden = true
//        planController.view.isHidden = true
//        mainView2.isHidden = true
    
        
        TimerState.instance.selectedTask <~ planController.tasksController.selectedTasks.producer.map { $0.first }
        
        
        if Config.isTrial {
            let trialButtonController = TrialButtonViewController()
            trialButtonController.layoutAttribute = .right
            
            self.addTitlebarAccessoryViewController(trialButtonController)
        }
    }

    
    @IBAction func showDailyPlan(_ sender: Any) {
        showPlan(detail: .daily)
    }
    
    @IBAction func showWeeklyPlan(_ sender: Any) {
        showPlan(detail: .weekly)
    }
    
    @IBAction func nextUnit(_ sender: Any) {
        planController.updateRange(change: 1)
    }
    
    @IBAction func previousUnit(_ sender: Any) {
        planController.updateRange(change: -1)
    }
    
    @IBAction func showProjects(_ sender: Any) {
    }
    
    func showProject(_ project: Project? = nil) {
        planController.view.isHidden = true
        mainView.isHidden = false
        if let project = project {
            backlogController.selectedProject.value = project
        }
        backlogController.view.isHidden = false
    }
    
    func showPlan(detail: PlanDetail? = nil) {
        backlogController.view.isHidden = true
        mainView.isHidden = false
        planController.view.isHidden = false
        
        if let detail = detail {
            switch detail {
            case .daily:
                planController.config.detail = .daily
                
            case .weekly:
                planController.config.detail = .weekly
            }
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
    let kTimerButton = "TimerButton"
    let kPreferencesButton = "PreferencesButton"
    let kImportButton = "ImportButton"
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [String] {
        return [
            NSToolbarFlexibleSpaceItemIdentifier,
            kTimerItem,
            kAddButton,
            kPreferencesButton,
            kImportButton
        ]
    }
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [String] {
        return [kImportButton, NSToolbarFlexibleSpaceItemIdentifier, kTimerItem, NSToolbarFlexibleSpaceItemIdentifier, kPreferencesButton]
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
        case kTimerButton:
            item.label = "Timer"
//            let button = NSButton(title: "Toggle Timer", target: self, action: #selector(toggleTimer))
            let image = #imageLiteral(resourceName: "TimerTemplate")
            let button = NSButton(image: image, target: self, action: #selector(toggleTimer))
            button.bezelStyle = .texturedRounded
            button.setContentHuggingPriority(125, for: .vertical)
            item.view = button
            
            return item
        case kPreferencesButton:
            item.label = "Preferences"
            let image = NSImage(named: NSImageNameActionTemplate)!
            let button = NSButton(image: image, target: self, action: #selector(showPreferences))
            button.bezelStyle = .texturedRounded
            button.setContentHuggingPriority(125, for: .vertical)
            item.view = button
            return item
            
        case kImportButton:
            item.label = "Import from OmniFocus"
            let image = #imageLiteral(resourceName: "ImportIconTemplate")
            let button = NSButton(image: image, target: self, action: #selector(importFromOmnifocus))
            button.bezelStyle = .texturedRounded
            button.setContentHuggingPriority(125, for: .vertical)
            button.toolTip = "Import from OmniFocus"
            item.view = button
            return item
            
        default:
            return nil
        }
    }
    
    func toggleTimer() {
        AppDelegate.instance?.toggleTimerWindow()
    }
    
    func showPreferences() {
        AppDelegate.instance?.showPreferences()
    }
    
    func importFromOmnifocus() {
        AppDelegate.instance?.importFromOmnifocus()
    }
    
}
