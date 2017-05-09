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
import Cartography

class TasksViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate, NSTextFieldDelegate, NSMenuDelegate {
    
    class RootItem {
    }
    
    @IBOutlet weak var outlineView: NSOutlineView!
    @IBOutlet weak var taskColumn: NSTableColumn!
    @IBOutlet weak var estimateColumn: NSTableColumn!
    @IBOutlet weak var projectColumn: NSTableColumn!
    
    @IBOutlet weak var planMenuItem: NSMenuItem!
    @IBOutlet weak var unplanMenuItem: NSMenuItem!
    
    
    let rootItem = RootItem()
    
    var heading = ""
    var tasks = [Task]()
    var weightKeypath = #keyPath(Task.weight)
    
    var wantsHighlightPlanned = true
    
    let draggedType = "TaskRow"
    
    let selectedTasks = MutableProperty<Set<Task>>(Set())
    
    var onCreate: (() -> ())?
    
    // MARK: - Lifecycle
    // ------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func reloadData() {
        Swift.print("🎧 Tasks list reloading data!")
        
        let items = outlineView.selectedRowIndexes.map {
            self.outlineView.item(atRow: $0)
        }
        
        outlineView.reloadData()
        
        var indexes = IndexSet()
        
        for item in items {
            let index = outlineView.row(forItem: item)
            if index != -1 {
                indexes.insert(index)
            }
        }
        
        outlineView.selectRowIndexes(indexes, byExtendingSelection: false)
    }
    
    override func viewDidAppear() {
        outlineView.expandItem(nil, expandChildren: true)
        
        outlineView.register(forDraggedTypes: [draggedType])
    }
    

    override func viewDidLayout() {
        var set = IndexSet()
        for i in 0...outlineView.numberOfRows {
            set.insert(i)
        }
        
        updateHeight(indexes: set)
    }
    
    // MARK: - Accessors
    // ------------------------------------------------------------------------
    
    func findSelectedTasks() -> Set<Task> {
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
    var estimateCellViews = [Task: TaskEstimateTableCellView]()
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if item is RootItem {
            return nil
//            return createHeaderView(outlineView, column: tableColumn)
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
            
            view?.wantsHighlightPlanned = wantsHighlightPlanned
            view?.task.value = task
            
            titleCellViews[task] = view
            view?.controller = self
            
            view?.onTabOut = {
                Swift.print("Tabbed out! estimate text field: \(self.estimateCellViews[task]?.textField)")
                
                self.estimateCellViews[task]?.startEditing()

            }
            
            return view
        }
        
        if column === estimateColumn {
            let view = outlineView.make(withIdentifier: "EstimateCell", owner: self) as! TaskEstimateTableCellView
            view.task.value = task
            
            estimateCellViews[task] = view
            
            return view
        }
        
        if column == projectColumn {
            let view = outlineView.make(withIdentifier: "ProjectCell", owner: self) as! TaskProjectTableCellView
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
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        selectedTasks.value = findSelectedTasks()
    }
    
    // MARK: - Actions
    // ------------------------------------------------------------------------
    
    @IBAction func create(_ sender: Any) {
        onCreate?()
    }
    
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
        
        for task in findSelectedTasks() {
            context.delete(task)
        }
        
        context.processPendingChanges()
        undo?.endUndoGrouping()
    }
    
    // MARK: - Planning
    // -----------------------------------------------------------------------
    
    @IBAction func planForToday(_ sender: Any) {
        for task in findSelectedTasks() {
            task.plannedFor = Date() as NSDate
        }
    }
    
    @IBAction func unplan(_ sender: Any) {
        for task in findSelectedTasks() {
            task.plannedFor = nil
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
            task.setValue(weight, forKey: weightKeypath)
            
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
                
                dummyTitleCellView.setContentHuggingPriority(1, for: .vertical)
                dummyTitleCellView.setContentHuggingPriority(NSLayoutPriorityRequired, for: .horizontal)
            }
            
            
            dummyTitleCellView.task.value = task
            
            // If there is a view for this project already, copy title from
            // there, as it may have changed
            if let view = titleCellViews[task] {
                dummyTitleCellView.textField?.stringValue = view.textField?.stringValue ?? ""
            }
        
            
            dummyTitleCellView.bounds.size.width = taskColumn.width
            dummyTitleCellView.bounds.size.height = 10
            dummyTitleCellView.setContentHuggingPriority(NSLayoutPriorityRequired, for: .horizontal)

            dummyTitleCellView.needsLayout = true
            dummyTitleCellView.layoutSubtreeIfNeeded()
            
            let size = dummyTitleCellView.fittingSize
            
            return size.height
        } else if item is RootItem {
            return 1
        }
        
        return 32
    }
    
    var nextWeight: Int64 {
        return (tasks.map({ task in
            return (task.value(forKey: weightKeypath) as? Int64) ?? 0
        }).max() ?? 0) + 1
    }
    
    func updateHeight(cellView: TaskTitleTableCellView) {
        let row = outlineView.row(for: cellView)
        
        updateHeight(indexes: IndexSet([row]))
    }
    
    func updateHeight(indexes: IndexSet) {
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 0
            outlineView.noteHeightOfRows(withIndexesChanged: indexes)
        }, completionHandler: nil)
    }
    
    // MARK: - Updating the menu
    // -----------------------------------------------------------------------
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        guard let task = findSelectedTasks().first else { return }
        
        if task.isPlanned {
            planMenuItem.isHidden = true
            unplanMenuItem.isHidden = false
        } else {
            planMenuItem.isHidden = false
            unplanMenuItem.isHidden = true
        }
        
    }
}
