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


class TimerState {
    static let instance = TimerState()
    
    let generalLane = TimerLane(id: .general)
    let pomodoroLane = TimerLane(id: .pomodoro)
    
    let runningProject = MutableProperty<Project?>(nil)
    let runningTask = MutableProperty<Task?>(nil)
    let selectedTask = MutableProperty<Task?>(nil)
    
    let isRunning = MutableProperty<Bool>(false)
    
    init() {
        
        isRunning <~ generalLane.isRunning
        
        runningProject <~ generalLane.runningEntry.producer.pick { $0.reactive.project }
        runningTask <~ generalLane.runningEntry.producer.pick { $0.reactive.task }
        
    }
    
    func start() {
        let task = selectedTask.value
        
        generalLane.start(task: task)
    }
    
    func stop() {
        generalLane.stop()
    }
}


