//
//  TaskProjectTableCellView.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/1/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit
import ReactiveSwift
import NiceData

class TaskProjectTableCellView: NSTableCellView {

    @IBOutlet var popup: NSPopUpButton!
    @IBOutlet var colorView: ProjectColorView!
    
    
    let projects = MutableProperty<[Project]>([])
    
    let task = MutableProperty<Task?>(nil)
    
    override func awakeFromNib() {
        
        projects <~ AppDelegate.allProjectsObserver.objects.producer
        
        projects.producer.take(during: reactive.lifetime).startWithValues { projects in
            self.popup.removeAllItems()
            
            for project in projects {
                self.popup.addItem(withTitle: project.name ?? "")
            }
        }
        
        let project = task.producer.pick({ $0.reactive.project.producer })
        
        project.take(during: reactive.lifetime).startWithValues { project in
            if let projectIndex = self.projects.value.index(where: { $0 == project }) {
                self.popup.selectItem(at: projectIndex)
            } else {
                self.popup.selectItem(at: -1)
            }
        }
        
        popup.reactive.selectedIndexes.take(during: reactive.lifetime).observeValues { index in
            if let project = self.projects.value.at(index) {
                self.task.value?.project = project
            }
        }
        
        colorView.project <~ project
        
//        AppDelegate.allProjectsObserver.objects.producer.startWithValues { projects in
//            
//        }
    }
}
