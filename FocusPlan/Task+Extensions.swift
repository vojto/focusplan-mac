//
//  Task+Extensions.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/1/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit

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
    
    func remove(in context: NSManagedObjectContext) {
        if (timerEntries ?? NSSet()).count > 0 {
            self.isRemoved = true
        } else {
            context.delete(self)
        }
    }
    
    static func create(in context: NSManagedObjectContext, weight: Int64, plannedFor: Date? = nil) -> Task {
        let project: Project? = context.findFirst()
        
        let task = Task(entity: Task.entity(), insertInto: context)
        task.project = project
        task.plannedFor = (plannedFor ?? Date()) as NSDate
        task.weightForPlan = weight
        
        return task
    }
}
