//
//  PomodoroType.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/3/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation

enum PomodoroType: String {
    case pomodoro = "pomodoro"
    case shortBreak = "shortBreak"
    case longBreak = "longBreak"
    
    var duration: TimeInterval {
        let defaults = UserDefaults.standard
        
        switch self {
        case .pomodoro:
            return Double(defaults.integer(forKey: PreferencesKeys.pomodoroMinutes) * 60)

        case .shortBreak:
            return Double(defaults.integer(forKey: PreferencesKeys.shortBreakMinutes) * 60)
            
        case .longBreak:
            return Double(defaults.integer(forKey: PreferencesKeys.longBreakMinutes) * 60)
        }
    }
    

}
