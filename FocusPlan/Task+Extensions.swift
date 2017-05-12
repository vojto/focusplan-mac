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
        self.estimatedMinutes = Int64(Formatting.parseMinutes(value: value))
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
    
    static func filter(tasks: [Task], onDay date: Date) -> [Task] {
        let startDate = date.startOf(component: .day)
        let endDate = date.endOf(component: .day)
        
        var result = [Task]()
        
        for task in tasks {
            guard let date = (task.plannedFor as Date?) else { continue }
            
            if date >= startDate && date < endDate {
                result.append(task)
            }
        }
        
        return result
    }
}
