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

public extension Reactive where Base: Task {
    var title: SignalProducer<String?, NoError> {
        return producer(forKeyPath: #keyPath(Task.title))
            .map(asString)
    }
    
    var estimatedMinutes: SignalProducer<Int?, NoError> {
        return producer(forKeyPath: #keyPath(Task.estimatedMinutes))
            .map(asInt)
    }
}
