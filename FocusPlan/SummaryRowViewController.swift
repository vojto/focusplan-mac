//
//  SummaryRowViewController.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/10/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Cocoa



class SummaryRowViewController: NSViewController {
    
    class ProjectSummary {
        var planned: TimeInterval = 0
        var spent: TimeInterval = 0
    }
    
    var events = [CalendarEvent]() {
        didSet {
            update()
        }
    }
    
    var stackView: NSStackView {
        return view as! NSStackView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        update()
    }
    
    func update() {
        // Calculate summary per project
        
        Swift.print("Updating with \(events.count) events!")
        
        var totals = [Project: ProjectSummary]()
        for event in events {
            guard let project = event.task?.project ?? event.timerEntry?.project else { continue }
            
            if totals[project] == nil {
                totals[project] = ProjectSummary()
            }
            
            let summary = totals[project]!
            
            if event.type == .task, let task = event.task {
                summary.planned += Double(task.estimatedMinutes) * 60
            }
            
            if event.type == .timerEntry, let entry = event.timerEntry, let duration = entry.duration {
                summary.spent += duration
            }
        }
        
        Swift.print("Totals: \(totals)")
        
//        let stats = ["foo", "bar"]
        
        
        let views = totals.map { (project, summary) -> NSView in
            
            let view = createItemView()
            
            let label = "\(Formatting.longFormat(timeInterval: summary.spent)) / \(Formatting.longFormat(timeInterval: summary.planned))"
            
            view.label.stringValue = label
            view.colorView.project.value = project
            
            return view
        }
        
        let spacer = NSView()
        spacer.setContentHuggingPriority(100, for: .horizontal)
        spacer.setContentHuggingPriority(100, for: .vertical)
        
        stackView.setViews([spacer] + views, in: .trailing)
    }
    
    func createItemView() -> SummaryRowItem {
        var views = NSArray()
        let nib = NSNib(nibNamed: "SummaryRowItem", bundle: nil)!
        nib.instantiate(withOwner: self, topLevelObjects: &views)
        
        return views.filter({ $0 is NSView }).first as! SummaryRowItem

    }
    
    
}