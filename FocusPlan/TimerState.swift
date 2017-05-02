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
    
    
    
    let currentEntryObserver: ReactiveObserver<TimerEntry> = {
        let context = AppDelegate.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: TimerEntry.entity().name!)
        request.sortDescriptors = [NSSortDescriptor(key: "startedAt", ascending: false)]
        request.fetchLimit = 1
        
        return ReactiveObserver<TimerEntry>(context: context, request: request)
    }()
    
    let currentEntry = MutableProperty<TimerEntry?>(nil)
    let currentRunningEntry = MutableProperty<TimerEntry?>(nil)
    let isRunning = MutableProperty<Bool>(false)
    
    let runningProject = MutableProperty<Project?>(nil)
    let runningTask = MutableProperty<Task?>(nil)
    
    let selectedTask = MutableProperty<Task?>(nil)
    
    init() {
        currentEntry <~ currentEntryObserver.objects.producer.map { $0.first }
        
        runningProject <~ currentRunningEntry.producer.pick { $0.reactive.project }
        runningTask <~ currentRunningEntry.producer.pick { $0.reactive.task }
        
        let isCurrentEntryRunning = currentEntry.producer.pick({ $0.reactive.isRunning.producer }).map({ $0 ?? false })
        
        currentRunningEntry <~ SignalProducer.combineLatest(
            isCurrentEntryRunning,
            currentEntry.producer
        ).map { running, entry -> TimerEntry? in
            if running {
                return entry
            } else {
                return nil
            }
        }
        
        isRunning <~ isCurrentEntryRunning
    }
    
    func start() {
        let task = selectedTask.value
        
        let context = AppDelegate.viewContext
        let entry = TimerEntry(entity: TimerEntry.entity(), insertInto: context)
        
        entry.startedAt = Date() as NSDate
        entry.task = task
        entry.project = task?.project
    }
    
    func stop() {
        guard let entry = currentEntry.value else { return }
        
        entry.endedAt = Date() as NSDate
    }
}
