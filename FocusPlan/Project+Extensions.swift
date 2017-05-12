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
}
