//
//  Project+.swift
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

public func asProject(_ value: Any?) -> Project? {
    return value as? Project
}

public extension Reactive where Base: Project {
    var name: SignalProducer<String?, NoError> {
        return producer(forKeyPath: #keyPath(Project.name))
            .map(asString)
    }
    
    var color: SignalProducer<String?, NoError> {
        return producer(forKeyPath: #keyPath(Project.color))
            .map(asString)
    }
    
    var tasks: SignalProducer<NSSet?, NoError> {
        return producer(forKeyPath: #keyPath(Project.tasks))
            .map(asNSSet)
    }
}
