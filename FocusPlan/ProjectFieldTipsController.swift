//
//  ProjectFieldTipsController.swift
//  Timelist
//
//  Created by Vojtech Rinik on 6/16/17.
//  Copyright © 2017 Vojtech Rinik. All rights reserved.
//

import Cocoa
import NiceData
import ReactiveSwift
import Cartography
import NiceKit

class ProjectFieldTipsController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet weak var tableView: NiceMenuTableView!
    
    let rowHeight: CGFloat = 26.0
    let verticalMargin: CGFloat = 5.0
    
    let searchTerm = MutableProperty<String>("")
    
    enum TipItem {
        case project(project: Project)
        case createProject
    }
    
    var projects = [Project]()
    
    var items: [TipItem] {
        let term = searchTerm.value
        
        let actionItems: [TipItem] = [.createProject]
        
        let projectItems = projects.filter({ project in
            
            
            if term != "" {
                return (project.name ?? "").lowercased().contains(term.lowercased())
            } else {
                return true
            }
        }).map({
            return TipItem.project(project: $0)
        })
        
        return actionItems + projectItems
    }
    
    var selectedItem: TipItem? {
        let row = tableView.selectedRow
        let item = items.at(row)
        
        return item
    }
    
    var heightConstraint: NSLayoutConstraint?
    
    var projectsObserver: ReactiveObserver<Project>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupProjectsObserver()
        
        projectsObserver.objects.producer.startWithValues { projects in
            self.projects = projects
            self.reloadTable()
        }
        
        searchTerm.producer.startWithValues { value in
            self.reloadTable()
        }
        
        constrain(view) { view in
            self.heightConstraint = (view.height == 100)
        }
        
        tableView.onDismiss = self.handleDismiss
        
        reloadTable()
    }
    
    override func viewWillDisappear() {
        searchTerm.value = ""
    }
    
    func setupProjectsObserver() {
        let context = AppDelegate.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Project")

        request.predicate = NSPredicate(format: "isFolder = 0")
        
        projectsObserver = ReactiveObserver<Project>(context: context, request: request)
    }
    
    // MARK: - Controlling the table
    
    func reloadTable() {
        tableView.reloadData()
        let spaceBetween = tableView.intercellSpacing.height
        let rows = CGFloat(tableView.numberOfRows)
        let height = rows * rowHeight + verticalMargin * 2 + spaceBetween * (rows)
        heightConstraint?.constant = height
    }
    
    // MARK: - Table data source
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
//        guard let view = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("Row"), owner: self) as? ProjectFieldTipCell else { assertionFailure(); return nil }

        guard let view = tableView.make(withIdentifier: "Row", owner: self) as? ProjectFieldTipCell else { return nil }
        
        let item = items[row]
        
        switch item {
        case .createProject:
            let term = searchTerm.value
            view.field.stringValue = (term != "") ? "Create '\(term)'" : "Create new"
        case .project(project: let project):
            view.field.stringValue = project.name ?? ""
        }
        
        return view
        
    }
    
    // MARK: - Table delegate
    
    /*
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
     */
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return rowHeight
    }
    
    func handleDismiss() {
        Swift.print("going to dismiss this thing...")
        
    }
}
