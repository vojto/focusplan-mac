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

extension NSTreeController {
    
    func indexPathOfObject(anObject:NSObject) -> NSIndexPath? {
        return self.indexPathOfObject(anObject: anObject, nodes: (self.arrangedObjects as AnyObject).children)
    }
    
    func indexPathOfObject(anObject:NSObject, nodes:[NSTreeNode]!) -> NSIndexPath? {
        for node in nodes {
            if (anObject == node.representedObject as! NSObject)  {
                return node.indexPath as NSIndexPath
            }
            if (node.children != nil) {
                if let path:NSIndexPath = self.indexPathOfObject(anObject: anObject, nodes: node.children)
                {
                    return path
                }
            }
        }
        return nil
    }
}

class ProjectsViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate, NSTextFieldDelegate, NSMenuDelegate {
    
    lazy var observer: ReactiveObserver<Project> = {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Project")
        return ReactiveObserver<Project>(context: AppDelegate.viewContext, request: request)
    }()
    
    
    
    @IBOutlet var treeController: NSTreeController!
    
    var rootItem: RootItem!
    var backlogHeaderItem: HeaderItem!

    
    var projects = [Project]() {
        didSet {

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
        
        backlogHeaderItem = HeaderItem(type: .backlog)
        rootItem = RootItem(children: [backlogHeaderItem])
    }
    
    override func viewDidAppear() {
        disposable += observer.objects.producer.startWithValues { projects in
            
            self.projects = projects.sorted { $0.weight < $1.weight }
            
//            self.outlineView.reloadData()
            
//            DispatchQueue.main.async {
//                self.ensureSelection()
//            }
        }
        
        // Do view setup here.
        outlineView.expandItem(nil, expandChildren: true)
        
        outlineView.register(forDraggedTypes: [draggedType])
        
        menuNeedsUpdate(contextMenu)
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
    
    /*
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return headerItems.count
        } else if let header = item as? HeaderItem {
            switch header.type {
            case .backlog:
                return projects.count
            case .plan:
                return planItems.count
            }
        }
        
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return headerItems[index]
        } else if let header = item as? HeaderItem {
            switch header.type {
            case .backlog:
                return projects[index]
            case .plan:
                return planItems[index]
            }
        } else {
            fatalError()
        }
    }
    */
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return true
    }
    
    // MARK: - Making views for outline view
    // ------------------------------------------------------------------------
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let node = item as? NSTreeNode else { return nil }
        let item = node.representedObject
        
        if let header = item as? HeaderItem {
            let view = outlineView.make(withIdentifier: "HeaderCell", owner: self) as? NSTableCellView
            
            view?.textField?.stringValue = header.type.rawValue
            
            return view
        } else if let project = (item as? ProjectItem)?.project {
            let view = outlineView.make(withIdentifier: "ProjectCell", owner: self) as! ProjectTableCellView
            
//            view.page.value = page
            
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
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        let obj = (item as? NSTreeNode)?.representedObject
        
        if obj is ProjectItem {
            return true
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
    
    
    @IBAction func addProject(_ sender: Any) {
        let context = AppDelegate.viewContext
        
        let project = Project.create(in: context, weight: projects.count + 1)
        
        try! context.save()
        
        select(project: project)
        
        DispatchQueue.main.async {
            self.edit(project: project)
        }
    }
    
    
    func edit(project: Project) {
        guard let item = backlogHeaderItem.children.filter({ ($0 as? ProjectItem)?.project == project }).first else { return }
        
        guard let path = treeController.indexPathOfObject(anObject: item) else { return }
        
        treeController.setSelectionIndexPaths([path as IndexPath])
        
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
    
    func outlineView(_ outlineView: NSOutlineView, writeItems items: [Any], to pasteboard: NSPasteboard) -> Bool {
        
        guard let project = items.first as? Project else { return false }
        guard let index = projects.index(of: project) else {
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
        } else if item is Project {
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
    
}
