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
        var children = [Item]()
        
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
    
    enum HeaderItemType: String {
        case plan = "PLAN"
        case backlog = "BACKLOG"
    }
    
    class HeaderItem: Item {
        var type: HeaderItemType
        
        init(type: HeaderItemType) {
            self.type = type
            super.init(children: [])
        }
    }
    
    class ProjectItem: Item {
        let project: Project
        
        init(project: Project) {
            self.project = project
            super.init(children: [])
        }
    }
    
}
