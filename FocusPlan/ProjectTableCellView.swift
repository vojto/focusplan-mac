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
    
    let isExpanded = MutableProperty<Bool>(false)
    
    @IBOutlet var colorPicker: ColorPicker?
    @IBOutlet var iconButton: NSButton?
    
    override func awakeFromNib() {
        setupField()
        
        setupColorPicker()
        
        setupIcon()
    }
    
    func setupField() {
        guard let field = textField else { return }
        
        field.font = NSFont.systemFont(ofSize: 14, weight: NSFontWeightRegular)
        field.textColor = NSColor(hexString: "353535")
    }
    
    func setupIcon() {
        let isFolder = project.producer.map { $0?.isFolder ?? false }
        
        let icon = SignalProducer.combineLatest(isFolder, isExpanded.producer).map { folder, expanded -> NSImage in
            if folder {
                return expanded ? #imageLiteral(resourceName: "FolderExpandedIcon") : #imageLiteral(resourceName: "FolderIcon")
            } else {
                return #imageLiteral(resourceName: "ProjectIcon")
            }
        }
        
        if let button = iconButton {
            button.reactive.image <~ icon
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
                outlineView.animator().collapseItem(item)
            } else {
                outlineView.animator().expandItem(item)
            }
        }
        
        
        
//        outlineView?.expandItem(item)
        
//        Swift.print("Expanding/collapsing!")
    }
}
