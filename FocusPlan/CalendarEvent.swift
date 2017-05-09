//
//  CalendarEvent.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/2/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation

enum CalendarEventType: String {
    case task
    case timerEntry
}

class CalendarEvent: CustomStringConvertible, Hashable {
    
    let type: CalendarEventType
    
    var task: Task?
    var timerEntry: TimerEntry?
    
    var startsAt: TimeInterval?
    var duration: TimeInterval
    
    var isHidden = false
    
    var date: Date? {
        if let task = self.task {
            return task.plannedFor as Date?
        } else if let entry = timerEntry {
            return entry.startedAt as Date?
        } else {
            return nil
        }
    }
    
    var startDate: Date? {
        if let startTime = startsAt {
            return Date().startOf(component: .day).addingTimeInterval(startTime)
        } else {
            return nil
        }
    }
    
    var endDate: Date? {
        return startDate?.addingTimeInterval(duration)
    }
    
    var hashValue: Int {
        if let task = self.task {
            return (31 &* type.hashValue) &+ task.hashValue
        } else if let entry = self.timerEntry {
            return (31 &* type.hashValue) &+ entry.hashValue
        } else {
            fatalError()
        }
    }
    
    static func ==(lhs: CalendarEvent, rhs: CalendarEvent) -> Bool {
        return lhs.hashValue == rhs.hashValue
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
    
    init(task: Task, startsAt: TimeInterval?, duration: TimeInterval) {
        self.type = .task
        self.task = task
        self.startsAt = startsAt
        self.duration = duration
    }
    
    init(timerEntry: TimerEntry, startsAt: TimeInterval?, duration: TimeInterval) {
        self.type = .timerEntry
        self.timerEntry = timerEntry
        self.startsAt = startsAt
        self.duration = duration
    }
    
    var description: String {
        return "<Event startsAt=\(startsAt) duration=\(duration)>"
    }
}
