//
//  TimeLane.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/2/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit
import ReactiveSwift
import NiceData

enum LaneId: String {
    case general = "general"
    case pomodoro = "pomodoro"
}

class TimerLane {
    let id: LaneId
    
    let currentEntry = MutableProperty<TimerEntry?>(nil)
    let runningEntry = MutableProperty<TimerEntry?>(nil)
    let isRunning = MutableProperty<Bool>(false)
    let runningSince = MutableProperty<Date?>(nil)
    /**
     If there is a running entry and it has a projected end, then `runningTill`
     contains projected end of that running entry.
     */
    let runningTill = MutableProperty<Date?>(nil)
    
    let currentEntryObserver: ReactiveObserver<TimerEntry>!
    
    init(id: LaneId) {
        self.id = id
        
        self.currentEntryObserver = {
            let context = AppDelegate.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: TimerEntry.entity().name!)
            
            request.predicate = NSPredicate(format: "lane = %@", id.rawValue)
            request.sortDescriptors = [NSSortDescriptor(key: "startedAt", ascending: false)]
            request.fetchLimit = 1
            
            return ReactiveObserver<TimerEntry>(context: context, request: request)
        }()
        
        currentEntry <~ currentEntryObserver.objects.producer.map { $0.first }
        
        let isCurrentEntryRunning = currentEntry.producer.pick({ $0.reactive.isRunning.producer }).map({ $0 ?? false })
        
        runningEntry <~ SignalProducer.combineLatest(
            currentEntry.producer,
            isCurrentEntryRunning
        ).map({ entry, running -> TimerEntry? in
                if running {
                    return entry
                } else {
                    return nil
                }
        })
    
        
        isRunning <~ isCurrentEntryRunning
        
        runningSince <~ runningEntry.producer.map { entry -> Date? in
            return entry?.startedAt as Date?
        }
        
        runningTill <~ runningEntry.producer.map({ entry -> Date? in
            return entry?.projectedEnd
        }).skipRepeats({ $0 == $1 })
    }
    
    func start(task: Task? = nil, type: String? = nil, targetDuration: TimeInterval? = nil, countPrevPomos: Int16 = 0) {
        Swift.print("🌈 Starting timer in \(id) lane!")
        
        let context = AppDelegate.viewContext
        let entry = TimerEntry(entity: TimerEntry.entity(), insertInto: context)
        
        entry.lane = id.rawValue
        entry.type = type
        entry.startedAt = Date() as NSDate
        entry.task = task
        entry.countPrevPomos = countPrevPomos
        
        if let duration = targetDuration {
            entry.targetDuration = duration
        }
        
        entry.project = task?.project
    }
    
    func stop() {
        guard let entry = runningEntry.value else { return }
        
        entry.endedAt = Date() as NSDate
    }
    
    
}
