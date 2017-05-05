//
//  CalendarEventsCollection.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/5/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit

extension Array {
    var lastIndex: Int {
        return count - 1
    }
}

class CalendarEventsCollection: CustomDebugStringConvertible {
//    var events = [CalendarEvent]()
    
    var sections = [[CalendarEvent]]()
    
    var debugDescription: String {
        return sections.debugDescription
    }
    
    var count: Int {
        var total = 0
        
        for section in sections {
            total += section.count
        }
        
        return total
    }
    
    func at(indexPath: IndexPath) -> CalendarEvent {
        return sections[indexPath.section][indexPath.item]
    }
    
    var allIndexPaths: [IndexPath] {
        var paths = [IndexPath]()
        
        for (i, section) in sections.enumerated() {
            for (j, _) in section.enumerated() {
                paths.append(IndexPath(item: j, section: i))
            }
        }
        
        return paths
    }
    
    func reset(sectionsCount: Int) {
        sections = []
        
        for _ in 0...(sectionsCount-1) {
            sections.append([])
        }
    }
    
    func append(event: CalendarEvent, section: Int) {
        if section > sections.lastIndex {
            for _ in (sections.lastIndex+1)...section {
                sections.append([])
            }
        }
        
        sections[section].append(event)
    }
    
    func indexPath(forEvent: CalendarEvent) -> IndexPath? {
        for (i, section) in sections.enumerated() {
            for (j, event) in section.enumerated() {
                if event === forEvent {
                    return IndexPath(item: j, section: i)
                }
            }
        }
        
        return nil
        
    }
    
    func moveItem(at: IndexPath, to: IndexPath) {
        let item = sections[at.section].remove(at: at.item)
        
        sections[to.section].insert(item, at: to.item)
    }
}
