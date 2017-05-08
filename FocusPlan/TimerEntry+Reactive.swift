//
//  TimerEntry+Reactive.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/1/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa
import NiceReactive
import enum Result.NoError

public extension Reactive where Base: TimerEntry {
    var startedAt: SignalProducer<Date?, NoError> {
        return producer(forKeyPath: #keyPath(TimerEntry.startedAt))
            .map(asDate)
    }
    
    var endedAt: SignalProducer<Date?, NoError> {
        return producer(forKeyPath: #keyPath(TimerEntry.endedAt))
            .map(asDate)
    }
    
    var duration: SignalProducer<TimeInterval?, NoError> {
        return SignalProducer.combineLatest(startedAt, endedAt).map { start, end -> TimeInterval? in
            guard let startedAt = (start as Date?), let endedAt = (end as Date?) else {
                return nil
            }
            
            return endedAt.timeIntervalSince(startedAt)
        }
    }
    
    var isRunning: SignalProducer<Bool, NoError> {
        return endedAt.map { $0 == nil }
    }
    
    var project: SignalProducer<Project?, NoError> {
        return producer(forKeyPath: #keyPath(TimerEntry.project))
            .map(asProject)
    }
    
    var task: SignalProducer<Task?, NoError> {
        return producer(forKeyPath: #keyPath(TimerEntry.task))
            .map(asTask)
    }

}
