//
//  UserDefaults+Extensions.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/12/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa
import NiceReactive
import enum Result.NoError

struct PreferencesKeys {
    static let wantsPomodoro = "wantsPomodoro"
    static let pomodoroMinutes = "pomodoroMinutes"
    static let shortBreakMinutes = "shortBreakMinutes"
    static let longBreakMinutes = "longBreakMinutes"
    static let longBreakEach = "longBreakEach"
}

extension Reactive where Base: UserDefaults {
    var wantsPomodoro: SignalProducer<Bool, NoError> {
        return producer(forKeyPath: PreferencesKeys.wantsPomodoro).map(asBool).map { $0 ?? false }
    }
    
    var pomodoroMinutes: SignalProducer<Int, NoError> {
        return producer(forKeyPath: PreferencesKeys.pomodoroMinutes).map(asInt).map { $0 ?? 0 }
    }
    
    var shortBreakMinutes: SignalProducer<Int, NoError> {
        return producer(forKeyPath: PreferencesKeys.shortBreakMinutes).map(asInt).map { $0 ?? 0 }
    }
    
    var longBreakMinutes: SignalProducer<Int, NoError> {
        return producer(forKeyPath: PreferencesKeys.longBreakMinutes).map(asInt).map { $0 ?? 0 }
    }
    
    var longBreakEach: SignalProducer<Int, NoError> {
        return producer(forKeyPath: PreferencesKeys.longBreakEach).map(asInt).map { $0 ?? 0 }
    }
    
    
}
