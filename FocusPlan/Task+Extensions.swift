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
    
    static func create(in context: NSManagedObjectContext, plannedFor: Date? = nil) -> Task {
        let task = Task(entity: Task.entity(), insertInto: context)
        task.plannedFor = (plannedFor ?? Date()) as NSDate
        
        task.moveToEndInPlannedList(in: context)
        task.moveToEndInProjectList(in: context)
        
        return task
    }
    
    static func findBy(externalId: String, in context: NSManagedObjectContext) -> Task? {
        let request = NSFetchRequest<Task>(entityName: self.entity().name!)
        
        request.predicate = NSPredicate(format: "externalId = %@", externalId)
        request.fetchLimit = 1
        
        let results = try! context.fetch(request)
        return results.first
    }
    
    func moveToEndInPlannedList(in context: NSManagedObjectContext) {
        guard let date = (plannedFor as Date?) else { return }
        
        let start = date.startOf(component: .day)
        let end = date.endOf(component: .day)
        
        let predicate = NSPredicate(format: "plannedFor >= %@ AND plannedFor < %@", start as NSDate, end as NSDate)
        
        moveToEnd(forWeightKey: #keyPath(weightForPlan), predicate: predicate, in: context)
    }
    
    func moveToEndInProjectList(in context: NSManagedObjectContext) {
        guard let project = self.project else { return }
        
        let predicate = NSPredicate(format: "project = %@", project)
        
        moveToEnd(forWeightKey: #keyPath(weight), predicate: predicate, in: context)
    }
    
    // Sets planned weight to number that will effectively put it
    // to the end of planned list for that day.
    func moveToEnd(forWeightKey key: String, predicate: NSPredicate, in context: NSManagedObjectContext) {
        let request = NSFetchRequest<Task>(entityName: entity.name!)
        
        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(key: key, ascending: false)]
        request.fetchLimit = 1
        
        let results = try! context.fetch(request)
        
        let nextWeight: Int
        if let task = results.first,
            let weight = task.value(forKey: key) as? Int64 {
            
            nextWeight = Int(weight) + 1
        } else {
            nextWeight = 0
        }

        self.setValue(Int64(nextWeight), forKey: key)
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

    func setProjectFromSelection(_ selection: ProjectField.ProjectSelection) {
        switch selection {
        case .new(let title):
            let project = self.createProject(title: title)

            self.project = project
            break
        case .existing(let project):
            self.project = project
        }
    }

    func createProject(title: String) -> Project? {
        let context = AppDelegate.viewContext

        guard let project = NSEntityDescription.insertNewObject(forEntityName: "Project", into: context) as? Project else { return nil }

        project.name = title
        project.moveToEndOfList(in: context)

        return project
    }
}
