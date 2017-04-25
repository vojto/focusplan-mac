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

class ProjectsViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate, NSTextFieldDelegate, NSMenuDelegate {
    
    lazy var observer: ReactiveObserver<Project> = {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Project")
        return ReactiveObserver<Project>(context: AppDelegate.viewContext, request: request)
    }()

    class RootItem {
    }
    
    let rootItem = RootItem()
    
    var projects = [Project]()
    
    let draggedType = "ProjectRow"
    
    var onSelect: ((Project) -> ())?
    
    @IBOutlet weak var outlineView: NSOutlineView!
    
    var disposable = CompositeDisposable()
    
    let selectedProject = MutableProperty<Project?>(nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear() {
        disposable += observer.objects.producer.startWithValues { projects in
            self.projects = projects.sorted { $0.weight < $1.weight }
            
            self.outlineView.reloadData()
        }
        
        // Do view setup here.
        outlineView.expandItem(nil, expandChildren: true)
        
        outlineView.register(forDraggedTypes: [draggedType])
        
        menuNeedsUpdate(contextMenu)
    }
    
    deinit {
        disposable.dispose()
    }
    
    // MARK: - Outline view data source
    // ------------------------------------------------------------------------
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return 1
        } else if item is RootItem {
            return projects.count
        } else {
            return 0
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return rootItem
        } else if item is RootItem {
            return projects[index]
        } else {
            fatalError()
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return true
    }
    
    // MARK: - Making views for outline view
    // ------------------------------------------------------------------------
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if item is RootItem {
            return outlineView.make(withIdentifier: "HeaderCell", owner: self) as? NSTableCellView
        } else if let project = item as? Project {
            
            let view = outlineView.make(withIdentifier: "ProjectCell", owner: self) as! NSTableCellView
            
//            view.page.value = page
            
            var name = project.name ?? ""
            
            if name == "" {
                name = "untitled"
                view.textField?.alpha = 0.5
            } else {
                view.textField?.alpha = 1
            }
            
            view.textField?.stringValue = name
            view.textField?.delegate = self
            
            return view
        }
        
        return nil
    }
    
    
    /*
    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        let id = "RowView"
        
        var rowView = outlineView.make(withIdentifier: id, owner: self) as! PagesOutlineRowView?
        
        if rowView == nil {
            rowView = PagesOutlineRowView(frame: NSZeroRect)
            rowView!.identifier = id
        }
        
        return rowView
    }
    */
    
    
    // Hides expansion arrows
    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        if item is RootItem {
            return false
        } else {
            return true
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldEdit tableColumn: NSTableColumn?, item: Any) -> Bool {
        return true
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        if let project = findSelectedProject() {
            selectedProject.value = project
            onSelect?(project)
        } else {
            selectedProject.value = nil
        }
    }
    
    func findSelectedProject() -> Project? {
        let row = outlineView.selectedRow
        let item = outlineView.item(atRow: row)
        
        return item as? Project
    }
    
    // MARK: - NSTextFieldDelegate
    
    override func controlTextDidBeginEditing(_ obj: Notification) {
        guard let field = obj.object as? NSTextField else { return }
        field.alpha = 1
    }
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        guard let field = obj.object as? NSTextField else { return }
        field.isEditable = false
        let value = field.stringValue
        
        let row = outlineView.row(for: field)
        let item = outlineView.item(atRow: row)
        
        if let project = item as? Project {
            project.name = value
            
            select(project: project)
        }
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
        
        let project = NSEntityDescription.insertNewObject(forEntityName: "Project", into: context) as! Project
        project.name = ""
        project.weight = Int32(projects.count + 1)
        
        try! context.save()
        
        select(project: project)
        
        DispatchQueue.main.async {
            self.edit(project: project)
        }
    }
    
    
    func edit(project: Project) {
        let row = outlineView.row(forItem: project)
        guard let view = outlineView.view(atColumn: 0, row: row, makeIfNecessary: false) as? NSTableCellView else { return assertionFailure() }
        guard let textField = view.textField else { return assertionFailure() }
        
        textField.isEditable = true
        
        outlineView.window!.makeFirstResponder(textField)
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
        
        let item = outlineView.item(atRow: row)
        
        if item is Project {
            let menuItem = NSMenuItem(title: "Remove", action: #selector(deleteProjectAction(_:)), keyEquivalent: "")
            menuItem.target = self
            contextMenu.addItem(menuItem)

        }
        
    }
    
    @IBAction func deleteProjectAction(_ sender: Any) {
        let row = outlineView.clickedRow
        
        if let project = outlineView.item(atRow: row) as? Project {
            deleteProject(project)
        }
    }
    
    func deleteProject(_ project: Project) {
        AppDelegate.viewContext.delete(project)
    }
    
    
    
    // MARK: - Page reordering
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
        undoManager.setActionName("Reorder pages")
        undoManager.endUndoGrouping()
        
        observer.fetch()
        
        select(row: newIndex + 1)
        
        return true
    }
    
}
