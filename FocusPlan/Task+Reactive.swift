//
//  Task+Reactive.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 4/26/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa
import NiceReactive
import enum Result.NoError

public func asTask(_ value: Any?) -> Task? {
    return value as? Task
}

public extension Reactive where Base: Task {
    var title: SignalProducer<String?, NoError> {
        return producer(forKeyPath: #keyPath(Task.title))
            .map(asString)
    }
    
    var estimatedMinutes: SignalProducer<Int?, NoError> {
        return producer(forKeyPath: #keyPath(Task.estimatedMinutes))
            .map(asInt)
    }
    
    var estimatedMinutesFormatted: SignalProducer<String, NoError> {
        return estimatedMinutes.map { minutes -> String in
            return Formatting.format(estimate: minutes)
        }
    }
    
    var isFinished: SignalProducer<Bool, NoError> {
        return producer(forKeyPath: #keyPath(Task.isFinished))
            .map(asBool).map { $0 ?? false }
    }
    
    var plannedFor: SignalProducer<Date?, NoError> {
        return producer(forKeyPath: #keyPath(Task.plannedFor))
            .map(asDate)
    }
    
    var isPlanned: SignalProducer<Bool, NoError> {
        return plannedFor.map { $0 != nil }
    }
    
    var project: SignalProducer<Project?, NoError> {
        return producer(forKeyPath: #keyPath(Task.project))
            .map({ $0 as? Project })
    }
}
