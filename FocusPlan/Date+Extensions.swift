//
//  Date+Extensions.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/1/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation

extension Date {
    var dayTimeInterval: TimeInterval {
        let start = self.startOf(component: .day)
        return self.timeIntervalSince(start)
    }
}
