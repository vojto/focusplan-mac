//
//  CalendarEvent.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/2/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation

enum CalendarEventType {
    case task
    case timerEntry
}

class CalendarEvent: CustomStringConvertible {
    let type: CalendarEventType
    
    var task: Task?
    var timerEntry: TimerEntry?
    
    let startsAt: Date
    let duration: TimeInterval
    
    var endsAt: Date {
        return startsAt.addingTimeInterval(duration)
    }
    
    var lane: PlanLane? {
        switch type {
        case .task:
            return .task
        case .timerEntry:
            guard let lane = LaneId(rawValue: timerEntry?.lane ?? "") else { return nil }
            
            switch lane {
            case .general:
                return .task
            case .pomodoro:
                return .pomodoro
            }
        }
    }
    
    init(task: Task, startsAt: Date, duration: TimeInterval) {
        self.type = .task
        self.task = task
        self.startsAt = startsAt
        self.duration = duration
    }
    
    init(timerEntry: TimerEntry, startsAt: Date, duration: TimeInterval) {
        self.type = .timerEntry
        self.timerEntry = timerEntry
        self.startsAt = startsAt
        self.duration = duration
    }
    
    var description: String {
        return "<Event startsAt=\(startsAt) duration=\(duration)>"
    }
}
