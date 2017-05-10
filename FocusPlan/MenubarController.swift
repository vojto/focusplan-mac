//
//  MenubarController.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/10/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit
import ReactiveSwift

fileprivate let kStartNextLabel = "Start next"
fileprivate let kPomodoroNextLabel = "Start Pomodoro"
fileprivate let kStartShortBreakLabel = "Start break"
fileprivate let kStartLongBreakLabel = "Start long break"


class MenubarController: NSObject {
    var statusItem: NSStatusItem!
    
    var menu: NSMenu!
    var taskItem: NSMenuItem!
    
    var startNextItem: NSMenuItem!
    var pomodoroNextItem: NSMenuItem!
    var startShortBreakItem: NSMenuItem!
    var startLongBreakItem: NSMenuItem!
    var stopItem: NSMenuItem!
    
    var showMainItem: NSMenuItem!
    
    var nextTask: Task?
    
    lazy var now = timer(interval: .seconds(1), on: QueueScheduler.main)
    
    lazy var state = {
        return TimerState.instance
    }()
    
    func setup() {
        self.menu = createMenu()

        self.statusItem = createStatusItem()
        
        let textStatus = SignalProducer.combineLatest(
            state.runningStatus.producer,
            now.producer
        ).map { status, date -> String in
                switch status {
                    
                case .pomodoro(type: let type, since: let since, duration: let duration):
                    return Formatting.formatPomodoro(type: type, since: since, duration: duration)
                    
                case .general(since: let since):
                    return Formatting.format(timeInterval: date.timeIntervalSince(since))
                    
                case .stopped:
                    return "-:--"
                    
                }
        }
        
        // Bind status
        
        statusItem.button?.title = "-:--"
        textStatus.producer.startWithValues { status in
            self.statusItem.button?.title = status
        }
        
        // Bind current task
        state.runningTask.producer.startWithValues { task in
            if let task = task {
                self.taskItem.title = "Current task: \(task.title ?? "")"
            } else {
                self.taskItem.title = "No task"
            }
        }
        
        // Bind next task title
        if let controller = PlanViewController.instance {
            let nextTask = controller.tasksObserver.sortedTasksForPlan.map { $0.first }
            
            nextTask.startWithValues { task in
                self.nextTask = task
                
                if let task = task {
                    self.startNextItem.title = "Start: \(task.title ?? "")"
                } else {
                    self.startNextItem.title = kStartNextLabel
                }
            }
        }
        
        
        // Bind buttons
        state.runningStatus.producer.startWithValues { status in
            switch status {
            case .stopped:
                self.stopItem.isHidden = true
                self.startNextItem.isHidden = false
                self.pomodoroNextItem.isHidden = false
                self.startShortBreakItem.isHidden = false
                self.startLongBreakItem.isHidden = false
            default:
                self.stopItem.isHidden = false
                self.startNextItem.isHidden = true
                self.pomodoroNextItem.isHidden = true
                self.startShortBreakItem.isHidden = true
                self.startLongBreakItem.isHidden = true
            }
        }

    }
    
    func createStatusItem() -> NSStatusItem {
        let item = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        
        //        item.button = NSButton(title: "serus", target: nil, action: "")
        
//        item.button?.image = #imageLiteral(resourceName: "Paradicka")
//        item.button?.title = "bazinga"
        item.button?.imagePosition = .imageLeading
        
        item.menu = self.menu
        
        return item
    }
    
    
    
    func createMenu() -> NSMenu {
    
        
        let menu = NSMenu()
        
        taskItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        menu.addItem(taskItem)
        
        
        menu.addItem(NSMenuItem.separator())
        
    
        stopItem = NSMenuItem(title: "Stop", action: #selector(stopTimer), keyEquivalent: "")
        stopItem.target = self
        menu.addItem(stopItem)
        
        
        startNextItem = NSMenuItem(title: kStartNextLabel, action: #selector(startNextTask), keyEquivalent: "")
        startNextItem.target = self
        menu.addItem(startNextItem)
        
        menu.addItem(NSMenuItem.separator())
        
        pomodoroNextItem = NSMenuItem(title: kPomodoroNextLabel, action: #selector(pomodoroNextTask), keyEquivalent: "")
        pomodoroNextItem.target = self
        menu.addItem(pomodoroNextItem)
        
        startShortBreakItem = NSMenuItem(title: kStartShortBreakLabel, action: #selector(startShortBreak), keyEquivalent: "")
        startShortBreakItem.target = self
        menu.addItem(startShortBreakItem)
        
        startLongBreakItem = NSMenuItem(title: kStartLongBreakLabel, action: #selector(startLongBreak), keyEquivalent: "")
        startLongBreakItem.target = self
        menu.addItem(startLongBreakItem)
        
        menu.addItem(NSMenuItem.separator())
        

        
        showMainItem = NSMenuItem(title: "Open FocusPlan", action: #selector(showMain), keyEquivalent: "")
        showMainItem.target = self
        menu.addItem(showMainItem)
        
        return menu
    }
    
    func stopTimer() {
        Swift.print("Stopping the timer")
        
        state.stop()
    }
    
    func startNextTask() {
        state.restartChangingTo(task: nextTask)
    }
    
    func pomodoroNextTask() {
        state.startPomodoro(type: .pomodoro, task: nextTask)
    }
    
    func startShortBreak() {
        state.startPomodoro(type: .shortBreak, task: nextTask)
    }

    func startLongBreak() {
        state.startPomodoro(type: .longBreak, task: nextTask)
    }
    
    func showMain() {
        AppDelegate.instance?.showMainWindow()
    }
    

}
