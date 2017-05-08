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
    
}
