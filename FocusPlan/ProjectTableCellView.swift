//
//  ProjectTableCellView.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 4/26/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit
import NiceKit
import NiceUI
import ReactiveSwift
import NiceReactive


class ProjectTableCellView: EditableTableCellView {
    let project = MutableProperty<Project?>(nil)
    var node: NSTreeNode?
    
    @IBOutlet var colorPicker: ColorPicker?
    @IBOutlet var colorView: ProjectColorView?
    @IBOutlet var folderIcon: NSButton?
    
    override func awakeFromNib() {
        setupColorPicker()
        
        colorView!.project <~ project.producer
        
        setupIcon()
    }
    
    func setupIcon() {
        project.producer.startWithValues { project in
            self.colorView?.isHidden = true
            self.folderIcon?.isHidden = true
        
            if let project = project {
                if project.isFolder {
                    self.folderIcon?.isHidden = false
                } else {
                    self.colorView?.isHidden = false
                }
            }
        }
    }
    
    func setupColorPicker() {
        guard let colorPicker = self.colorPicker else { return }
        
        colorPicker.colors = Palette.colors.map { NSColor(hexString: $0.area0)! }
        colorPicker.selectedColor = colorPicker.colors.first
        colorPicker.wantsAuto = false
        colorPicker.onChange = { nsColor in
            guard let colorName = Palette.encode(color: nsColor) else { return }
            self.project.value?.color = colorName
        }
        
        let color = project.producer.pick { $0.reactive.color }
        color.startWithValues { colorName in
            guard let nsColor = Palette.decode(colorName: colorName) else { return }
            colorPicker.selectedColor = nsColor
        }
    }
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        super.controlTextDidEndEditing(obj)
        
        guard let field = obj.object as? NSTextField else { return }
        let value = field.stringValue
        
        project.value?.name = value
    }
    
    @IBAction func toggleExpand(_ sender: AnyObject) {
        guard let outlineView = self.outlineView else { return }
        guard let item = self.node else { return }
        
        // TODO: find out why we have to do it throug main
        DispatchQueue.main.async {
            if outlineView.isItemExpanded(item) {
                outlineView.collapseItem(item)
            } else {
                outlineView.expandItem(item)
            }
        }
        
        
        
//        outlineView?.expandItem(item)
        
//        Swift.print("Expanding/collapsing!")
    }
}
