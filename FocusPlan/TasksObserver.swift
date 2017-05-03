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
    init(wantsPlannedOnly: Bool, wantsUnfinishedOnly: Bool = false, in context: NSManagedObjectContext) {
        let request: NSFetchRequest<NSFetchRequestResult> = Task.fetchRequest()
        
        var predicates = [NSPredicate]()
        
        if wantsPlannedOnly {
            predicates.append(NSPredicate(format: "isPlanned = true"))
        }
        
        if wantsUnfinishedOnly {
            predicates.append(NSPredicate(format: "isFinished = false"))
        }
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        super.init(context: context, request: request)
    }
    
    public var sortedTasksForPlan: SignalProducer<[Task], NoError> {
        return objects.producer.map { tasks in
            return tasks.sorted { task1, task2 in
                return task1.weightForPlan < task2.weightForPlan
            }
        }
    }
}
