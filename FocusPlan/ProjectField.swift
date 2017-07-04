//
//  ProjectField.swift
//  Timelist
//
//  Created by Vojtech Rinik on 6/16/17.
//  Copyright © 2017 Vojtech Rinik. All rights reserved.
//

import Cocoa
import Cartography
import ReactiveSwift
import NiceKit

class ProjectField: NiceField {

    var optionsPopover: NicePopover?
    var tipsController = ProjectFieldTipsController()

    override open var width: CGFloat {
        return 120.0
    }

    enum ProjectSelection {
        case existing(Project)
        case new(String)
    }

    var onSelect: ((ProjectSelection) -> ())?
    
    override func setup() {
        super.setup()

        tipsController.searchTerm <~ field.reactive.continuousStringValues

        tipsController.onClickSelected = self.handleClickSelectedInController
    }

    override func startEditing() {
        super.startEditing()

        if optionsPopover == nil {
            optionsPopover = NicePopover()
        }
        
        optionsPopover!.show(
            viewController: tipsController,
            parentWindow: self.window!,
            view: self,
            edge: .minY,
            size: NSSize(width: width, height: 150.0)
        )
        
        if let menuTable = tipsController.tableView as? NiceMenuTableView {
            menuTable.selectNone()
        }
        
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        guard let menuTable = tipsController.tableView as? NiceMenuTableView else { assertionFailure(); return }
        
        menuTable.selectDefault()
    }
    

    
    override open func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        
        guard let menuTable = tipsController.tableView as? NiceMenuTableView else { assertionFailure(); return false }
        
        if commandSelector == #selector(NSResponder.insertNewline(_:)) {
            self.confirmSelection()
        } else if commandSelector == #selector(NSResponder.moveUp(_:)) {
            menuTable.moveSelectionUp()
        } else if commandSelector == #selector(NSResponder.moveDown(_:)) {
            menuTable.moveSelectionDown()
        } else if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
            self.finishEditing()
        }
        
        return true
    }

    override func controlTextDidEndEditing(_ obj: Notification) {
        self.finishEditing()
    }
    
    override func finishEditing() {
        Swift.print("specific class finishing editing")

        window?.makeFirstResponder(nil)

        optionsPopover?.hide()

        if field.stringValue == "" {
            field.stringValue = "No project"
        }

        super.finishEditing()
    }

    func handleClickSelectedInController() {
        confirmSelection()
    }

    func confirmSelection() {
        if let item = tipsController.selectedItem {
            switch item {
            case .project(project: let project):
                onSelect?(.existing(project))
            case .createProject:
                let title = field.stringValue
                onSelect?(.new(title))
            }
        }

        finishEditing()
    }
    
}
