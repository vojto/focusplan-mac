//
//  TimerViewController.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/1/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit
import ReactiveSwift
import NiceData


class TimerViewController: NSViewController {
    lazy var state = TimerState.instance
    
    
    @IBOutlet weak var toggleButton: NSSegmentedControl!
    @IBOutlet weak var startButton: NSButton?
    @IBOutlet weak var stopButton: NSButton?
    
    @IBOutlet weak var toggleMenu: NSMenu!
    
    
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var projectSection: NSView!
    @IBOutlet weak var projectLabel: NSTextField!
    @IBOutlet weak var projectColor: ProjectColorView!
    @IBOutlet weak var taskPopup: NSPopUpButton!
    
    


    
    override func awakeFromNib() {
        statusLabel.font = NSFont.systemFont(ofSize: 11, weight: NSFontWeightMedium).monospaced()
        
        setupTaskPopup()
        

        
        let isTaskSelected = state.selectedTask.producer.map { $0 != nil }
        let isRunning = state.isRunning.producer
        
        toggleButton.reactive.isEnabled <~ SignalProducer.combineLatest(
            isTaskSelected,
            isRunning
        ).map { selected, running -> Bool in
            return !(!running && !selected)
        }
        
        isRunning.startWithValues { running in
            if running {
                self.toggleButton.setImage(#imageLiteral(resourceName: "StopTemplate"), forSegment: 0)
            } else {
                self.toggleButton.setImage(#imageLiteral(resourceName: "StartTemplate"), forSegment: 0)
            }
        }

        
        let textStatus =
        
        /*
        let status = SignalProducer.combineLatest(state.isRunning.producer, currentTime.producer).map { running, date -> String in
            
            if let pomodoroStart = self.state.pomodoroLane.runningSince.value as Date?,
                let entry = self.state.pomodoroLane.currentEntry.value {
                
         
                
            } else if let generalStart = self.state.generalLane.runningSince.value as Date? {
                
                let time = date.timeIntervalSince(generalStart)
                
                return Formatting.format(timeInterval: time)
            } else {
                return "No timer running."
            }
        }
        */
        
        statusLabel.reactive.stringValue <~ state.textStatus
        
        projectSection.reactive.isHidden <~ state.isRunning.map({ !$0 })
        projectLabel.reactive.stringValue <~ state.runningProject.producer.pick({ $0.reactive.name.producer }).map({ $0 ?? "" })
        projectColor.project <~ state.runningProject
        
        
        taskPopup.reactive.isHidden <~ state.isRunning.map({ !$0 })
//        taskLabel.reactive.stringValue <~ state.runningTask.producer.pick({ $0.reactive.title.producer }).map({ $0 ?? "" })

    }
    
    
    var tasksObserver: TasksObserver!
    var nextTasks = [Task]()
    
    func setupTaskPopup() {
        let context = AppDelegate.viewContext
        let popup = taskPopup
        
        tasksObserver = TasksObserver(wantsPlannedOnly: true, wantsUnfinishedOnly: true, in: context)
        tasksObserver.range = (Date().startOf(component: .day), Date().endOf(component: .day))
        
        tasksObserver.sortedTasksForPlan.producer.startWithValues { tasks in
            self.nextTasks = tasks
            
            guard let popup = popup else { return }
            
            let selected = popup.indexOfSelectedItem
            
            popup.removeAllItems()
            
            popup.addItem(withTitle: "No task")
            
            for task in tasks {
                popup.addItem(withTitle: task.title ?? "")
            }
            
            popup.selectItem(at: selected)
        }
        
        state.runningTask.producer.startWithValues { task in
            guard let task = task else {
                popup?.selectItem(at: 0)
                return
            }
            
            if let index = self.nextTasks.index(of: task) {
                Swift.print("Index of running task: \(index)")
                Swift.print("Selecting in poopup: \(index + 1)")
                
                popup?.selectItem(at: index + 1)
            } else {
                Swift.print("Running task has no index")
                
                popup?.selectItem(at: 0)
            }
        }
    }
    
    @IBAction func changeRunningTask(_ sender: Any) {
        let index = taskPopup.indexOfSelectedItem
        if let task = nextTasks.at(index - 1) {
            state.restartChangingTo(task: task)
        }
    }
    
    
    @IBAction func toggleButtonClicked(_ sender: Any) {
        let index = toggleButton.selectedSegment
        
        if index == 0 {
            toggleTimer()
        } else if index == 1 {
            let size = toggleButton.frame.size
            
            toggleMenu.popUp(positioning: nil, at: NSPoint(x: size.width - 16, y: size.height), in: toggleButton)
        }
    }
    
    func toggleTimer() {
        if state.isRunning.value {
            state.stop()
        } else {
            startSimple(self)
        }
    }
    
    @IBAction func startSimple(_ sender: Any) {
        state.start()
    }
    
    @IBAction func startPomodoro(_ sender: Any) {
        state.startPomodoro(type: .pomodoro)
    }
    
    @IBAction func startShortBreak(_ sender: Any) {
        state.startPomodoro(type: .shortBreak)
    }
    
    @IBAction func startLongBreak(_ sender: Any) {
        state.startPomodoro(type: .longBreak)
    }
    
    

    
}
