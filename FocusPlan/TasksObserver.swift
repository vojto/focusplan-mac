//
//  TasksObserver.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/2/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit
import NiceData
import ReactiveSwift
import enum Result.NoError

class TasksObserver: ReactiveObserver<Task> {
    let wantsPlannedOnly: Bool
    let wantsUnfinishedOnly: Bool
    var skipsArchived = false
    var project: Project?
    let context: NSManagedObjectContext
    
    var range: (Date, Date)? {
        didSet {
            update()
        }
    }
    
    init(wantsPlannedOnly: Bool, wantsUnfinishedOnly: Bool = false, in context: NSManagedObjectContext, includeProperties: Bool = true) {
        self.wantsPlannedOnly = wantsPlannedOnly
        self.wantsUnfinishedOnly = wantsUnfinishedOnly
        self.context = context

        super.init(context: context, request: nil, includeChanges: includeProperties ? .all : .none, callback: nil)
    }
    
    func createRequest() -> NSFetchRequest<NSFetchRequestResult> {
        let request: NSFetchRequest<NSFetchRequestResult> = Task.fetchRequest()
        
        var predicates = [NSPredicate]()
        
        predicates.append(NSPredicate(format: "isRemoved != YES"))
        
        if skipsArchived {
            predicates.append(NSPredicate(format: "isArchived != YES"))
        }
        
        if wantsPlannedOnly {
            predicates.append(NSPredicate(format: "plannedFor != nil"))
        }
        
        if wantsUnfinishedOnly {
            predicates.append(NSPredicate(format: "isFinished = false"))
        }
        
        if let project = self.project {
            predicates.append(NSPredicate(format: "project = %@", project))
        }
        
        if let range = self.range {
            predicates.append(NSPredicate(
                format: "plannedFor >= %@ AND plannedFor <= %@",
                range.0.startOf(component: .day) as NSDate,
                range.1.endOf(component: .day) as NSDate
            ))
        }
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        return request
    }
    
    func update() {
        self.request = createRequest()
    }
    
    public var sortedTasksForPlan: SignalProducer<[Task], NoError> {
        return objects.producer.map { tasks in
            return tasks.sorted { task1, task2 in
                return task1.weightForPlan < task2.weightForPlan
            }
        }
    }
    
    public var sortedForProject: SignalProducer<[Task], NoError> {
        return objects.producer.map { tasks in
            return tasks.sorted { task1, task2 in
                return task1.weight < task2.weight
            }
        }
    }
}
