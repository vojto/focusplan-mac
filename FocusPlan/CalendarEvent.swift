//
//  CalendarEvent.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/2/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation

class CalendarEvent: CustomStringConvertible {
    var task: Task?
    var timerEntry: TimerEntry?
    
    let startsAt: Date
    let duration: TimeInterval
    
    var endsAt: Date {
        return startsAt.addingTimeInterval(duration)
    }
    
    init(task: Task, startsAt: Date, duration: TimeInterval) {
        self.task = task
        self.startsAt = startsAt
        self.duration = duration
    }
    
    init(timerEntry: TimerEntry, startsAt: Date, duration: TimeInterval) {
        self.timerEntry = timerEntry
        self.startsAt = startsAt
        self.duration = duration
    }
    
    var description: String {
        return "<Event startsAt=\(startsAt) duration=\(duration)>"
    }
}
