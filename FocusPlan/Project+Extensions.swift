//
//  Project+Extensions.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 12/05/2017.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit

extension Project {
    static func create(in context: NSManagedObjectContext, weight: Int? = nil) -> Project {
        let project = Project(entity: Project.entity(), insertInto: context)
        project.name = ""
        project.color = "blue"
        
        if let weight = weight {
            project.weight = Int32(weight)
        }
        
        return project
    }
    
    func moveToEndOfList(in context: NSManagedObjectContext) {
        let request = NSFetchRequest<Project>(entityName: Project.entity().name!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "weight", ascending: false)]
        request.fetchLimit = 1
        
        let results = try! context.fetch(request)
        
        self.weight = (results.first?.weight ?? 0) + 1
    }
    
    static func findBy(externalId: String, in context: NSManagedObjectContext) -> Project? {
        let request = NSFetchRequest<Project>(entityName: Project.entity().name!)
        
        request.predicate = NSPredicate(format: "externalId = %@", externalId)
        request.fetchLimit = 1
        
        let results = try! context.fetch(request)
        
        return results.first
    }
}
