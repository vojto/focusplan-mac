//
//  Formatting.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/2/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation

class Formatting {
    public static func format(timeInterval: TimeInterval) -> String {
        var time = timeInterval
        
        if time < 0 {
            time = 0
        }
        
        let minutes = Int(floor(time / 60))
        
        let seconds = Int((time - Double(minutes * 60)))
        
        return NSString(format: "%02d:%02d", minutes, seconds) as String
    }
}
