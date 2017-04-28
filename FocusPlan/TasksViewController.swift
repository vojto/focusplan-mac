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

class TasksViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate, NSTextFieldDelegate, NSMenuDelegate {
    
    class RootItem {
    }
    
    @IBOutlet weak var outlineView: NSOutlineView!
    @IBOutlet weak var taskColumn: NSTableColumn!
    @IBOutlet weak var estimateColumn: NSTableColumn!
    
    @IBOutlet weak var planMenuItem: NSMenuItem!
    @IBOutlet weak var unplanMenuItem: NSMenuItem!
    
    
    let rootItem = RootItem()
    
    var heading = ""
    var tasks = [Task]()
    
    let draggedType = "TaskRow"
    
    // MARK: - Lifecycle
    // ------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func reloadData() {
        tasks.sort(by: { (task1, task2) -> Bool in
            task1.weight < task2.weight
        })
        
        outlineView.reloadData()
    }
    
    override func viewDidAppear() {
        outlineView.expandItem(nil, expandChildren: true)
        
        outlineView.register(forDraggedTypes: [draggedType])
    }
    
    // MARK: - Accessors
    // ------------------------------------------------------------------------
    
    var selectedTasks: Set<Task> {
        var tasks = Set<Task>()
        
        for index in outlineView.selectedRowIndexes {
            if let task = outlineView.item(atRow: index) as? Task {
                tasks.insert(task)
            }
        }
        
        return tasks
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
    
    var titleCellViews = [Task: TaskTitleTableCellView]()
    
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
            view?.textField?.stringValue = self.heading
            return view
        }
        return nil // no header view for now
    }
    
    func createTaskView(_ outlineView: NSOutlineView, column: NSTableColumn?, task: Task) -> NSView? {
        if column === taskColumn {
            let view = outlineView.make(withIdentifier: "TaskCell", owner: self) as? TaskTitleTableCellView
            
            view?.task.value = task
            
            titleCellViews[task] = view
            view?.controller = self
            
            return view
        }
        
        if column === estimateColumn {
            let view = outlineView.make(withIdentifier: "EstimateCell", owner: self) as! TaskEstimateTableCellView
            view.task.value = task
            return view
        }
        
        return nil
    }
    
    // MARK: Row view
    

    
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
    
    
    func edit(task: Task) {
        let row = outlineView.row(forItem: task)
        
        guard let columnIndex = outlineView.tableColumns.index(of: taskColumn) else { return assertionFailure() }
        guard let view = outlineView.view(atColumn: columnIndex, row: row, makeIfNecessary: false) as? NSTableCellView else { return assertionFailure() }
        guard let textField = view.textField else { return assertionFailure() }
        
        textField.isEditable = true
        
        outlineView.window!.makeFirstResponder(textField)
    }
    
    // MARK: - Removing
    // -----------------------------------------------------------------------
    
    @IBAction func removeTask(_ sender: Any) {
        let context = AppDelegate.viewContext
        let undo = context.undoManager
        
        context.processPendingChanges()
        undo?.beginUndoGrouping()
        
        for task in selectedTasks {
            context.delete(task)
        }
        
        context.processPendingChanges()
        undo?.endUndoGrouping()
    }
    
    // MARK: - Planning
    // -----------------------------------------------------------------------
    
    @IBAction func planForToday(_ sender: Any) {
        for task in selectedTasks {
            task.isPlanned = true
        }
    }
    
    @IBAction func unplan(_ sender: Any) {
        for task in selectedTasks {
            task.isPlanned = false
        }
    }
    
    
    
    // MARK: - Reordering
    // -----------------------------------------------------------------------
    
    func outlineView(_ outlineView: NSOutlineView, writeItems items: [Any], to pasteboard: NSPasteboard) -> Bool {
        
        guard let task = items.first as? Task else { return false }
        guard let index = tasks.index(of: task) else {
            return false
        }
        
        let data = NSKeyedArchiver.archivedData(withRootObject: ["index": index])
        pasteboard.declareTypes([draggedType], owner: self)
        pasteboard.setData(data, forType: draggedType)
        
        return true
    }
    
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        if item is RootItem {
            if index != NSOutlineViewDropOnItemIndex {
                return .move
            } else {
                return []
            }
        } else if item is Task {
            let itemIndex = outlineView.childIndex(forItem: item!)
            if index == NSOutlineViewDropOnItemIndex {
                outlineView.setDropItem(rootItem, dropChildIndex: itemIndex)
            } else if index == 0 {
                outlineView.setDropItem(rootItem, dropChildIndex: itemIndex+1)
            }
            return .move
        }
        
        
        return []
    }
    
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        let pasteboard = info.draggingPasteboard()
        let data = pasteboard.data(forType: draggedType)!
        guard let object = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: Int] else { return false }
        guard let pageIndex = object["index"] else { return false }
        
        var tasks = self.tasks
        
        let newIndex = pageIndex >= index ? index : index-1
        tasks.insert(tasks.remove(at: pageIndex), at: newIndex)
        
        let context = AppDelegate.viewContext
        let undoManager = AppDelegate.undoManager
        
        context.processPendingChanges()
        undoManager.beginUndoGrouping()
        
        var weight = 0
        for task in tasks {
            task.weight = Int64(weight)
            
            weight += 1
        }
        
        context.processPendingChanges()
        undoManager.setActionName("Reorder tasks")
        undoManager.endUndoGrouping()
        
        reloadData()
        
        outlineView.select(row: newIndex + 1)
        
        return true
    }
    
    // MARK: - Calculating the height
    // -----------------------------------------------------------------------
    
    var dummyTitleCellView: TaskTitleTableCellView!
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        if let task = item as? Task {
            if dummyTitleCellView == nil {
                dummyTitleCellView = outlineView.make(withIdentifier: "TaskCell", owner: self) as! TaskTitleTableCellView
            }
            
            
            dummyTitleCellView.task.value = task
            
            // If there is a view for this project already, copy title from
            // there, as it may have changed
            if let view = titleCellViews[task] {
                dummyTitleCellView.textField?.stringValue = view.textField?.stringValue ?? ""
            }
            
            dummyTitleCellView.bounds.size.width = taskColumn.width
            
            dummyTitleCellView.needsLayout = true
            dummyTitleCellView.layoutSubtreeIfNeeded()
            
            return dummyTitleCellView.fittingSize.height
        }
        
        return 32
    }
    
    func updateHeight(cellView: TaskTitleTableCellView) {
        let row = outlineView.row(for: cellView)
        
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 0
            outlineView.noteHeightOfRows(withIndexesChanged: IndexSet([row]))
        }, completionHandler: nil)
        
    }
    
    // MARK: - Updating the menu
    // -----------------------------------------------------------------------
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        guard let task = selectedTasks.first else { return }
        
        if task.isPlanned {
            planMenuItem.isHidden = true
            unplanMenuItem.isHidden = false
        } else {
            planMenuItem.isHidden = false
            unplanMenuItem.isHidden = true
        }
        
    }
}
