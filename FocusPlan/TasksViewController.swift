//
//  TasksViewController.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 4/26/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Cocoa
import NiceData
import ReactiveSwift

class TasksViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate, NSTextFieldDelegate {
    
    class RootItem {
    }
    
    @IBOutlet weak var outlineView: NSOutlineView!
    @IBOutlet weak var taskColumn: NSTableColumn!
    @IBOutlet weak var estimateColumn: NSTableColumn!
    
    let rootItem = RootItem()
    var project = MutableProperty<Project?>(nil)
    var tasks = [Task]()
    
    /*
    lazy var observer: ReactiveObserver<Task> = {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Project")
        return ReactiveObserver<Project>(context: AppDelegate.viewContext, request: request)
    }()
    */
    
    // MARK: - Lifecycle
    // ------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        
        project.producer.pick({ $0.reactive.tasks.producer }).startWithValues { tasks in
            if let tasks = tasks as? Set<Task> {
                self.tasks = Array(tasks).sorted(by: { (task1, task2) -> Bool in
                    task1.weight < task2.weight
                })
            } else {
                self.tasks = []
            }
            
            self.outlineView.reloadData()
        }
    }
    
    override func viewDidAppear() {
        outlineView.expandItem(nil, expandChildren: true)
    }
    
    // MARK: - Outline view basics
    // ------------------------------------------------------------------------
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return 1
        } else if item is RootItem {
            return tasks.count
        } else {
            return 0
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return rootItem
        } else if item is RootItem {
            return tasks[index]
        } else {
            fatalError()
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if item is RootItem {
            return true
        } else {
            return false
        }
        
    }
    
    // MARK: - Making views for outline view
    // ------------------------------------------------------------------------
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if item is RootItem {
            return createHeaderView(outlineView, column: tableColumn)
        } else if let task = item as? Task {
            return createTaskView(outlineView, column: tableColumn, task: task)
        }
        
        return nil
    }
    
    func createHeaderView(_ outlineView: NSOutlineView, column: NSTableColumn?) -> NSView? {
        if column === taskColumn {
            let view = outlineView.make(withIdentifier: "HeaderCell", owner: self) as? NSTableCellView
            view?.textField?.stringValue = self.project.value?.name ?? ""
            return view
        }
        return nil // no header view for now
    }
    
    func createTaskView(_ outlineView: NSOutlineView, column: NSTableColumn?, task: Task) -> NSView? {
        if column === taskColumn {
            let view = outlineView.make(withIdentifier: "TaskCell", owner: self) as? TaskTitleTableCellView
            
            view?.task.value = task
            
            return view
        }
        
        if column === estimateColumn {
            return nil // todo: return estimate view
        }
        
        return nil
    }
    
    // MARK: - Outline view selection
    // ------------------------------------------------------------------------
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        if item is RootItem {
            return false
        } else {
            return true
        }
    }
    
    // MARK: - Adding a task
    // ------------------------------------------------------------------------
    
    @IBAction func createTask(_ sender: Any) {
        guard let project = self.project.value else { return }
        
        
  
        let context = AppDelegate.viewContext
        let task = Task(entity: Task.entity(), insertInto: context)
        
        let nextWeight = (tasks.map({ $0.weight }).max() ?? 0) + 1
        
        task.title = ""
        task.weight = nextWeight
        task.project = project
        
        DispatchQueue.main.async {
            self.edit(task: task)
        }
    }
    
    func edit(task: Task) {
        let row = outlineView.row(forItem: task)
        
        guard let columnIndex = outlineView.tableColumns.index(of: taskColumn) else { return assertionFailure() }
        guard let view = outlineView.view(atColumn: columnIndex, row: row, makeIfNecessary: false) as? NSTableCellView else { return assertionFailure() }
        guard let textField = view.textField else { return assertionFailure() }
        
        textField.isEditable = true
        
        outlineView.window!.makeFirstResponder(textField)
    }
    
    
}
