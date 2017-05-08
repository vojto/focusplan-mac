//
//  Formatting.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/2/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation

class Formatting {
    public static func format(timeInterval: TimeInterval?) -> String {
        guard var time = timeInterval else {
            return ""
        }
        
        if time < 0 {
            time = 0
        }
        
        let minutes = Int(floor(time / 60))
        
        let seconds = Int((time - Double(minutes * 60)))
        
        return NSString(format: "%02d:%02d", minutes, seconds) as String
    }
    
    public static func format(estimate minutes: Int?) -> String {
        guard let minutes = minutes, minutes > 0 else {
            return ""
        }
        
        let hours = minutes / 60
        let extraMinutes = minutes - (hours*60)
        
        if hours > 0 {
            if extraMinutes > 0 {
                return "\(hours)h \(extraMinutes)m"
            } else {
                return "\(hours)h"
            }
        } else {
            return "\(minutes)m"
        }
    }
}
