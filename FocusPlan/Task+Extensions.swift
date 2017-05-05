//
//  Task+Extensions.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/1/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation

extension Task {
    var estimate: TimeInterval {
        var minutes = estimatedMinutes
        
        if minutes == 0 {
            minutes = 60
        }
        
        return Double(minutes) * 60
    }

    var isPlanned: Bool {
        return plannedFor != nil
    }
    
    func setEstimate(fromString value: String) {
        var minutes: Int?
        
        if let match = value.match(regex: "^\\s*(\\d+)\\s*m?\\s*$") {
            // "   123   "
            minutes = Int(match[1])
        } else if let match = value.match(regex: "^\\s*(\\d+)\\s*h\\s*$") {
            // "   123   h  "
            minutes = (Int(match[1]) ?? 0) * 60
        } else if let match = value.match(regex: "^\\s*(\\d+)\\s*h\\s*(\\d+)\\s*m?\\s*$") {
            // "   123   h  30m "
            minutes = (Int(match[1]) ?? 0) * 60 + (Int(match[2]) ?? 0)
        } else {
            minutes = nil
        }
        
        self.estimatedMinutes = Int64(minutes ?? 0)
    }
}
