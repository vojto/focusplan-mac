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
        switch self {
        case .pomodoro:
            return 30           // temp values
        case .shortBreak:
            return 15
        case .longBreak:
            return 20
        }
    }
}
