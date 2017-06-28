//
//  ProjectsViewController.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 4/25/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Cocoa
import NiceData
import ReactiveSwift
import NiceKit

class ProjectsViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate, NSTextFieldDelegate, NSMenuDelegate {
    
    lazy var observer: ReactiveObserver<Project> = {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Project")
        request.predicate = NSPredicate(format: "parent == nil")
    
        request.sortDescriptors = [
            NSSortDescriptor(key: "isFolder", ascending: false),
            NSSortDescriptor(key: "weight", ascending: true)
        ]
        
        let observer = ReactiveObserver<Project>(context: AppDelegate.viewContext, request: request)
        
//        let observer = ReactiveObserver<Project>(context: AppDelegate.viewContext, request: request, includeChanges: .none, callback: nil)
        
        return observer
    }()
    
    
    @IBOutlet var treeController: NSTreeController!
    
    var rootItem: RootItem!
    var backlogHeaderItem: HeaderItem!

    
    var projects = [Project]() {
        didSet {
            Swift.print("🌈 Setting projects!")
            backlogHeaderItem.children = projects.map { ProjectItem(project: $0) }
            let paths = treeController.selectionIndexPaths
            treeController.content = rootItem.children
            treeController.setSelectionIndexPaths(paths)
        }
    }
    
    let draggedType = "ProjectRow"
    
    var onSelect: ((Project?) -> ())?
    
    @IBOutlet weak var outlineView: NSOutlineView!
    
    var disposable = CompositeDisposable()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let todayHeaderItem = HeaderItem(type: .today)
        let nextHeaderItem = HeaderItem(type: .next)
        
        backlogHeaderItem = HeaderItem(type: .backlog)
        
        rootItem = RootItem(children: [todayHeaderItem, nextHeaderItem, backlogHeaderItem])
    }
    
    override func viewDidAppear() {
        disposable += observer.objects.producer.startWithValues { projects in
            self.projects = projects
        }
        
        // Do view setup here.
        
        outlineView.expandItem(nil, expandChildren: true)
        
        outlineView.register(forDraggedTypes: [draggedType])
        
        menuNeedsUpdate(contextMenu)
        
        setupInitialExpandCollapseStatus()
    }
    
    func ensureSelection() {
        let selectedRow = outlineView.selectedRow
        
        if selectedRow < 0, outlineView.numberOfRows > 1 {
            select(row: 1)
        }
    }
    
    deinit {
        disposable.dispose()
    }
    
    // MARK: - Outline view data source
    // ------------------------------------------------------------------------
    
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return true
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldCollapseItem item: Any) -> Bool {
        Swift.print("Should collapse item [\(item)]?")
        
        return true
    }
    
    func view(forNotification notification: Notification) -> NSView? {
        guard let info = notification.userInfo else { return nil }
        guard let node = info["NSObject"] as? NSTreeNode else { return nil }
        
        let row = outlineView.row(forItem: node)
        
        return outlineView.view(atColumn: 0, row: row, makeIfNecessary: false)
    }
    
    
    
    // MARK: - Making views for outline view
    // ------------------------------------------------------------------------
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let node = item as? NSTreeNode else { return nil }
        let item = node.representedObject
        
        if let header = item as? HeaderItem {
            switch header.type {
            case .today, .next:
                let view = outlineView.make(withIdentifier: "ActionHeaderCell", owner: self) as! ProjectsActionHeaderCell
                
                view.field.stringValue = header.type.rawValue
                
                if header.type == .today {
                    view.type = .today
                } else if header.type == .next {
                    view.type = .next
                }
                
                return view
            case .backlog:
                let view = outlineView.make(withIdentifier: "HeaderCell", owner: self) as? NSTableCellView
                view?.textField?.stringValue = header.type.rawValue
                return view
            }
            
        } else if let project = (item as? ProjectItem)?.project {
            let view = outlineView.make(withIdentifier: "ProjectCell", owner: self) as! ProjectTableCellView
            
            view.outlineView = outlineView
            view.node = node
            view.project.value = project
            
            var name = project.name ?? ""
            
            if name == "" {
                name = "untitled"
                view.textField?.alpha = 0.5
            } else {
                view.textField?.alpha = 1
            }
            
            view.textField?.stringValue = name
            
            return view
        }
        
        return nil
    }
    
    
    // Hides expansion arrows
    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
//        return false
        return true
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        guard let node = item as? NSTreeNode else { return 32 }
        let object = node.representedObject
        
        if let header = object as? HeaderItem {
            if header.type == .backlog {
                return 64
            }
        } else if object is SpaceItem {
            return 10
        }
        
        
        return 32
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {        
        let obj = (item as? NSTreeNode)?.representedObject
        
        if obj is ProjectItem {
            return true
        } else if let header = obj as? HeaderItem {
            switch header.type {
            case .today, .next:
                return true
            default:
                return false
            }
        } else {
            return false
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldEdit tableColumn: NSTableColumn?, item: Any) -> Bool {
        return true
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        let row = outlineView.selectedRow
        let item = outlineView.item(atRow: row)
        
        if let item = (item as? NSTreeNode)?.representedObject as? ProjectItem {
            onSelect?(item.project)
        }
    }
    
    func findSelectedProject() -> Project? {
        let row = outlineView.selectedRow
        let item = outlineView.item(atRow: row)
        
        return item as? Project
    }
    
    // MARK: - Actions
    
    //
    //    @IBAction func clickAction(_ sender: Any) {
    //        if outlineView.clickedRow == -1 {
    //            outlineView.deselectAll(self)
    //        }
    //    }
    
    
    @IBOutlet weak var addProjectButton: NSButton!
    @IBOutlet var addProjectMenu: NSMenu!
    
    @IBAction func showAddProjectMenu(_ sender: Any) {
        addProjectMenu.popUp(positioning: nil, at: NSPoint(x: 0, y: addProjectButton.frame.size.height + 4), in: addProjectButton)
    }
    
    @IBAction func addProject(_ sender: Any) {
        let context = AppDelegate.viewContext
        
        let project = Project.create(in: context)
        project.moveToEndOfList(in: context)
        
        try! context.save()
        
        selectAndEdit(project: project)
    }
    
    @IBAction func addFolder(_ sender: Any) {
        let context = AppDelegate.viewContext
        
        let project = Project.create(in: context)
        project.moveToEndOfList(in: context)
        project.isFolder = true
        
        try! context.save()
        
    }
    
    func selectAndEdit(project: Project) {
        DispatchQueue.main.async {
            if let index: Int = self.projects.index(of: project) {
                let indexes: [Int] = [0, index]
                let path = IndexPath(indexes: indexes)
                
                self.treeController.setSelectionIndexPath(path)
                
                self.editSelected()
            }
        }
    }
    
    func editSelected() {
        
        let index = outlineView.selectedRow
        if let view = outlineView.view(atColumn: 0, row: index, makeIfNecessary: false) as? EditableTableCellView {
            view.startEditing()
        }
    }
    
    
    func select(project: Project) {
        let index = outlineView.row(forItem: project)
        select(row: index)
    }
    
    func select(row: Int) {
        outlineView.select(row: row)
    }
    
    func deleteSelection(_ sender: Any) {
        let row = outlineView.selectedRow
        
        if let project = findSelectedProject() {
            deleteProject(project)
        }
        
        select(row: row)
    }
    
    // MARK: - Providing menu items & menu actions
    // -----------------------------------------------------------------------
    
    
    @IBOutlet var contextMenu: NSMenu!
    //    @IBOutlet weak var deletePageItem: NSMenuItem!
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        let row = outlineView.clickedRow
        
        contextMenu.removeAllItems()
        
        let item = (outlineView.item(atRow: row) as? NSTreeNode)?.representedObject
        
        if item is ProjectItem {
            let menuItem = NSMenuItem(title: "Remove", action: #selector(deleteProjectAction(_:)), keyEquivalent: "")
            menuItem.target = self
            contextMenu.addItem(menuItem)

        }
        
    }
    
    @IBAction func deleteProjectAction(_ sender: Any) {
        let row = outlineView.clickedRow
        
        if let project = ((outlineView.item(atRow: row) as? NSTreeNode)?.representedObject as? ProjectItem)?.project {
            deleteProject(project)
        }
    }
    
    func deleteProject(_ project: Project) {
        if let tasks = project.tasks as? Set<Task> {
            let tasks = tasks.filter { !$0.isRemoved && !$0.isArchived }
            
            if tasks.count > 0 {
                let alert = NSAlert()
                
                alert.messageText = "Delete project?"
                alert.informativeText = "You still have \(tasks.count) tasks in this project. Deleting this project will delete your tasks too. Are you sure?"
                alert.icon = nil
                
                alert.alertStyle = .warning
                
                alert.addButton(withTitle: "Delete")
                alert.addButton(withTitle: "Cancel")
                
                alert.buttons[1].keyEquivalent = "\r"
                alert.buttons[0].keyEquivalent = ""
                
                let result = alert.runModal()
                
                if result != NSAlertFirstButtonReturn {
                    return
                }
            }
        }
        
        AppDelegate.viewContext.delete(project)
    }
    
    
    
    // MARK: - Reordering
    // -----------------------------------------------------------------------
    
    var draggedItem: Item?
    
    func outlineView(_ outlineView: NSOutlineView, writeItems items: [Any], to pasteboard: NSPasteboard) -> Bool {
        
        guard let node = items.first as? NSTreeNode else { return false }
        guard let item = node.representedObject as? Item else { return false }
        
        // Ony project items (projects and folders) can be dragged
        if item is ProjectItem {
            // TODO: Set local variable
            
            // Maybe we can omit this section?
            let data = NSKeyedArchiver.archivedData(withRootObject: ["foo": "bar"])
            pasteboard.declareTypes([draggedType], owner: self)
            pasteboard.setData(data, forType: draggedType)
            
            draggedItem = item
            
            return true
        }
        
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        
        guard let proposedNode = item as? NSTreeNode else { return [] }
        guard let proposedItem = proposedNode.representedObject as? Item else { return [] }
        
        if proposedItem is SpaceItem {
            // There's no dropping on spaces
            // TODO: We should instead drop on the following item in the structure
            return []
        }
        
        if let item = proposedItem as? ProjectItem, !item.project.isFolder {
            // There's no dropping on projects
            return []
        }
        
        // No dropping of parents onto their children
        
        
        Swift.print("Proposed drop: \(proposedItem) : \(index)")
        // Check if we're moving it into itself?
        
        return .move
        
        /*
        if item is RootItem {
            if index != NSOutlineViewDropOnItemIndex {
                return .move
            } else {
                return []
            }
        } else if item is ProjectItem {
            let itemIndex = outlineView.childIndex(forItem: item)
            if index == NSOutlineViewDropOnItemIndex {
                outlineView.setDropItem(rootItem, dropChildIndex: itemIndex)
            } else if index == 0 {
                outlineView.setDropItem(rootItem, dropChildIndex: itemIndex+1)
            }
            return .move
        }
         */
        
    }
    
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        
        draggedItem = nil
        return false
        
        let pasteboard = info.draggingPasteboard()
        let data = pasteboard.data(forType: draggedType)!
        guard let object = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: Int] else { return false }
        guard let pageIndex = object["index"] else { return false }
        
        var projects = self.projects
        
        let newIndex = pageIndex >= index ? index : index-1
        projects.insert(projects.remove(at: pageIndex), at: newIndex)
        
        let context = AppDelegate.viewContext
        let undoManager = AppDelegate.undoManager
        
        context.processPendingChanges()
        undoManager.beginUndoGrouping()
        
        var weight = 0
        for project in projects {
            project.weight = Int32(weight)
            
            weight += 1
        }
        
        context.processPendingChanges()
        undoManager.setActionName("Reorder projects")
        undoManager.endUndoGrouping()
        
        observer.fetch()
        
        select(row: newIndex + 1)
        
        return true
    }
    
    // MARK: - Passing expand/collapse status to view
    
    func setupInitialExpandCollapseStatus() {
        for i in 0...(outlineView.numberOfRows-1) {
            let item = outlineView.item(atRow: i)
            let isExpanded = outlineView.isItemExpanded(item)
            
            if let view = outlineView.view(atColumn: 0, row: i, makeIfNecessary: false) as? ProjectTableCellView {
                view.isExpanded.value = isExpanded
            }
        }
        
        
    }
    
    func outlineViewItemDidCollapse(_ notification: Notification) {
        if let view = self.view(forNotification: notification) as? ProjectTableCellView {
            view.isExpanded.value = false
        }
    }
    
    func outlineViewItemDidExpand(_ notification: Notification) {
        if let view = self.view(forNotification: notification) as? ProjectTableCellView {
            view.isExpanded.value = true
        }
    }
    
}
