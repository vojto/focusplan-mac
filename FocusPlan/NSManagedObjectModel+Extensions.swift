//
//  Models.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 4/28/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit

/*
public extension NSManagedObject {
    static func findFirst<T: NSManagedObject>(in context: NSManagedObjectContext) -> T? {
        let request = NSFetchRequest<T>(entityName: )
        
        let results = try? context.fetch(request)
        
        return results?.first
    }
}
*/

public extension NSManagedObjectContext {
    func findFirst<T: NSManagedObject>() -> T? {
        let request = T.self.fetchRequest()
        
        let results = try? self.fetch(request)
        
        return results?.first as! T?
    }
}
