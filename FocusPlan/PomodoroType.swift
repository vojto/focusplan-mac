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
            return 25 * 60           // temp values
        case .shortBreak:
            return 5 * 60
        case .longBreak:
            return 15 * 60
        }
    }
}
