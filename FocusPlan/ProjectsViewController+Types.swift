//
//  ProjectsViewController+Types.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/12/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation

extension ProjectsViewController {
    
    @objc class Item: NSObject {
        var parent: Item?
        
        var children = [Item]() {
            didSet {
                for child in children {
                    child.parent = self
                }
            }
        }
        
        var parents: Set<Item> {
            if let parent = self.parent {
                return Set<Item>([parent]).union(parent.parents)
            } else {
                return Set()
            }
        }
        
        var parentsAndSelf: Set<Item> {
            return parents.union(Set([self]))
        }
        
        init(children: [Item]) {
            self.children = children
        }
        
        var isLeaf: Bool {
            return children.count == 0
        }
        
        var childCount: Int {
            return children.count
        }
    }
    
    class RootItem: Item {
        
    }
    
    class SpaceItem: Item {
        override var description: String {
            return "<🛰>"
        }
    }
    
    enum HeaderItemType: String {
        case today = "Today"
        case next = "Next"
        case backlog = "PROJECTS"
    }
    
    class HeaderItem: Item {
        var type: HeaderItemType
        
        init(type: HeaderItemType) {
            self.type = type
            super.init(children: [])
        }
        
        override var children: [ProjectsViewController.Item] {
            get {
                var children: [ProjectsViewController.Item] = []
                
                // Spacer items are disabled for now because they cause a lot
                // of trouble when reordering
                for child in super.children {
                    children.append(child)
                    
//                    if let projectItem = child as? ProjectItem, !projectItem.project.isFolder {
//                        continue
//                    }
//
//                    children.append(SpaceItem(children: []))
                }
                
                return children
            }
            
            set {
                super.children = newValue
            }
        }
        
        override var description: String {
            return "<Header type=\(type)>"
        }
    }
    
    class ProjectItem: Item {
        let project: Project
        
        init(project: Project) {
            self.project = project
            
            if project.isFolder {
                let items = project.sortedChildren.map({ ProjectItem(project: $0) })
                super.init(children: items)
            } else {
                super.init(children: [])
            }
        }
        
        override func isEqual(_ object: Any?) -> Bool {
            if let other = object as? ProjectItem {
                return other.project == self.project
            }
            
            return false
        }
        
        override var description: String {
            let type = project.isFolder ? "Folder" : "Project"
            return "<Project name=\(project.name ?? "")>"
        }
    }
    
}

