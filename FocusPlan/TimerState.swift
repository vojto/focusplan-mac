//
//  TimerState.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/1/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import ReactiveSwift
import NiceData
import AppKit

class TimerState: NSObject, NSUserNotificationCenterDelegate {
    static let instance = TimerState()
    
    let generalLane = TimerLane(id: .general)
    let pomodoroLane = TimerLane(id: .pomodoro)
    
    let runningProject = MutableProperty<Project?>(nil)
    let runningTask = MutableProperty<Task?>(nil)
    let selectedTask = MutableProperty<Task?>(nil)
    
    let isRunning = MutableProperty<Bool>(false)
    
    override init() {
        super.init()
        
        isRunning <~ generalLane.isRunning
        
        runningProject <~ generalLane.runningEntry.producer.pick { $0.reactive.project }
        runningTask <~ generalLane.runningEntry.producer.pick { $0.reactive.task }
        
        pomodoroLane.runningTill.producer.startWithValues { projectedEnd in
            self.handleProjectedEndChanged(projectedEnd)
        }
    }
    
    func start() {
        let task = selectedTask.value
        
        generalLane.start(task: task)
    }
    
    func startPomodoro(type: PomodoroType) {
        let task = selectedTask.value
     
        // When starting Pomodoro, just ensure that regular tracking is running.
        if !generalLane.isRunning.value {
            generalLane.start(task: task)
        }
        
        // But for Pomodoro lane, stop the running cycle and start a new one.
        pomodoroLane.stop()
        pomodoroLane.start(task: task, type: type.rawValue, targetDuration: type.duration)
    }
    
    func stop() {
        if generalLane.isRunning.value {
            generalLane.stop()
        }
        
        if pomodoroLane.isRunning.value {
            pomodoroLane.stop()
        }
    }
    
    func handleProjectedEndChanged(_ projectedEnd: Date?) {
        
        
        let center = NSUserNotificationCenter.default
        center.delegate = self
        
        for notif in center.scheduledNotifications {
            center.removeScheduledNotification(notif)
        }
        
        guard let entry = pomodoroLane.runningEntry.value else { return }
        guard let date = projectedEnd else { return }
        guard let type = PomodoroType(rawValue: entry.type ?? "") else { return }
        
        let notif = NSUserNotification()
        
        switch type {
        case .pomodoro:
            notif.title = "🍅 Pomodoro finished!"
            notif.informativeText = "Start the break when you're ready."
            notif.otherButtonTitle = "Start break"
        case .shortBreak, .longBreak:
            notif.title = "💤 Break finished!"
            notif.informativeText = "Start another Pomodoro when you're ready."
            notif.otherButtonTitle = "Start Pomodoro"
        }
        
        notif.deliveryDate = projectedEnd
        
        notif.hasActionButton = true
        notif.actionButtonTitle = "Later"
        notif.soundName = NSUserNotificationDefaultSoundName
        
        center.scheduleNotification(notif)
        
        Swift.print("Scheduled notification to fire in \(date.timeIntervalSinceNow) seconds!")
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        
        // Dismiss... Nothing to do.
        
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didDismissAlert notification: NSUserNotification) {
        
        // Start the next cycle
        
        guard let entry = pomodoroLane.runningEntry.value else { return }
        guard let type = PomodoroType(rawValue: entry.type ?? "") else { return }
        
        let nextType: PomodoroType
        
        switch type {
        case .pomodoro:
            nextType = .shortBreak
        case .shortBreak, .longBreak:
            nextType = .pomodoro
        }
        
        startPomodoro(type: nextType)
    }
    

}


