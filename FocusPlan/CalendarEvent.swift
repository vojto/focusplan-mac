//
//  CalendarEvent.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/2/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation

enum CalendarEventType: String {
    case project
    case task
    case timerEntry
}

class CalendarEvent: CustomStringConvertible, Hashable {
    
    let type: CalendarEventType
    
    var project: Project?
    
    var task: Task?
    var timerEntry: TimerEntry?
    
    var startsAt: TimeInterval?
    
    var duration: TimeInterval {
        if subtractsSpentDuration {
            let duration = plannedDuration - spentDuration
            if duration >= 0 {
                return duration
            } else {
                return 0
            }
        } else {
            if spentDuration > plannedDuration {
                return spentDuration
            } else {
                return plannedDuration
            }
        }
    }
    
    var subtractsSpentDuration = false
    
    var spentDuration: TimeInterval = 0
    var plannedDuration: TimeInterval = 0
    
    var isHidden = false
    
    var date: Date?
    
    /*{
        if let project = self.project {
            return projectEntryDate
        } else if let task = self.task {
            return task.plannedFor as Date?
        } else if let entry = timerEntry {
            return entry.startedAt as Date?
        } else {
            return nil
        }
    }*/
    
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
        case .project:
            return .project
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
    
    init(project: Project, date: Date, startsAt: TimeInterval?, duration: TimeInterval) {
        self.type = .project
        self.project = project
        self.date = date
//        self.projectEntryDate = date
        self.startsAt = startsAt
        self.plannedDuration = duration
    }
    
    init(task: Task, startsAt: TimeInterval?, duration: TimeInterval) {
        self.type = .task
        self.task = task
        self.date = task.plannedFor as Date?
        self.startsAt = startsAt
        self.plannedDuration = duration
    }
    
    init(timerEntry: TimerEntry, startsAt: TimeInterval?, duration: TimeInterval) {
        self.type = .timerEntry
        self.timerEntry = timerEntry
        self.date = timerEntry.startedAt as Date?
        self.startsAt = startsAt
        self.plannedDuration = duration
    }
    
    var description: String {
        return "<Event type=\(type) date=\(String(describing: date)) startsAt=\(String(describing: startsAt)) duration=\(duration)>"
    }
}
