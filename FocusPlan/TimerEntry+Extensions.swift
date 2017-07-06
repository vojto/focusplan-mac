//
//  TimerEntry+Extensions.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/2/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation

extension TimerEntry {
    var isRunning: Bool {
        return endedAt == nil
    }
    
    var duration: TimeInterval? {
        guard let startedAt = (self.startedAt as Date?), let endedAt = (self.endedAt as Date?) else {
            return nil
        }
        
        return endedAt.timeIntervalSince(startedAt)
    }
    
    var elapsed: TimeInterval {
        guard let startedAt = self.startedAt else {
            return 0
        }
        
        return Date().timeIntervalSince(startedAt as Date)
    }
    
    var projectedEnd: Date? {
        if let startedAt = self.startedAt, targetDuration > 0 {
            return (startedAt as Date).addingTimeInterval(targetDuration)
        } else {
            return nil
        }
    }
    
    static func sumDurations(timerEntries: [TimerEntry], includeCurrent: Bool) -> TimeInterval {
        var total: TimeInterval = 0
        
        for entry in timerEntries {
            if let duration = entry.duration {
                total += duration
            } else if let startedAt = entry.startedAt, entry.endedAt == nil, includeCurrent {
                let durationSoFar = Date().timeIntervalSince(startedAt as Date)
                total += durationSoFar
            }
        }
        
        return total
    }
    
    static func filter(entries: [TimerEntry], onDay date: Date) -> [TimerEntry] {
        var result = [TimerEntry]()
        
        let dayStart = date.startOf(component: .day)
        let dayEnd = date.endOf(component: .day)
        
        for entry in entries {
            guard let date = (entry.startedAt as Date?) else { continue }
            
            if date >= dayStart && date < dayEnd {
                result.append(entry)
            }
        }
        
        return result
    }
    
}
