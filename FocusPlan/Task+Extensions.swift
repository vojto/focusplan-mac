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
}
