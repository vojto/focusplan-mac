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
}
