//
//  TaskPlanTableCellView.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/11/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit
import ReactiveSwift
import NiceReactive
import SwiftDate

class TaskPlanTableCellView: NSTableCellView {
    
    @IBOutlet var popupWrapper: TaskPlanWrapperView!
    @IBOutlet var popup: NSPopUpButton!
    var select: ReactiveSelect<Date>!
    
    let task = MutableProperty<Task?>(nil)
    
    override func awakeFromNib() {
        
        select = ReactiveSelect(button: popup, allowsNone: true)
        
        let date = task.producer.pick { $0.reactive.plannedFor.producer }.map { $0?.startOf(component: .day) }
        
        let options = date.map { taskDate -> [Date] in
            var options = [Date]()
            
            let nextWeekEnd = (Date() + 1.week).endOf(component: .weekOfYear)
            
            var i = 0
            while true {
                let date = (Date() + i.days).startOf(component: .day)
                
                if date > nextWeekEnd {
                    break
                }
                
                if date.isInWeekend {
                    i += 1
                    continue
                }
                
                options.append(date)
                i += 1
            }
            
            if let taskDate = taskDate {
                if !options.contains(taskDate) {
                    options.insert(taskDate, at: 0)
                }
            }
            
            return options
        }
        
        select.label = { self.format(date: $0) }
        select.rac_values <~ options
        
        select.rac_selectedValue <~ date
        
        select.onChange = { date in
            Swift.print("Changed to: \(date)")
            
            self.task.value?.plannedFor = date as NSDate?
        }
        
        date.producer.startWithValues { date in
            self.popupWrapper.wantsHighlight = (date != nil)
        }
    }
    
    func format(date: Date) -> String {
        let now = Date()
        let thisWeekStart = now.startOf(component: .weekOfYear)
        let thisWeekEnd = now.endOf(component: .weekOfYear)
        let nextWeekStart = (now + 1.week).startOf(component: .weekOfYear)
        let nextWeekEnd = (now + 1.week).endOf(component: .weekOfYear)
        
        if date.isToday {
            return "Today"
        } else if date.isTomorrow {
            return "Tomorrow"
        } else if date.isYesterday {
            return "Yesterday"
        } else if date >= thisWeekStart && date <= thisWeekEnd {
            return "This " + date.string(custom: "EEEE")
        } else if date >= nextWeekStart && date <= nextWeekEnd {
            return "Next " + date.string(custom: "EEEE")
        } else {
            return date.string(custom: "MMM d")
        }
    }
}
