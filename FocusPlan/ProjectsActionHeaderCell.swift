//
//  ProjectsActionHeaderCell.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 6/27/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Cocoa
import Cartography

class ProjectsActionHeaderCell: NSTableCellView {
    
    var field = NSTextField()
    
    enum ActionType {
        case today
        case next
    }
    
    var type: ActionType = .today {
        didSet {
            update()
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        let imageView = NSImageView()
        addSubview(imageView)
        
        constrain(imageView) { imageView in
            imageView.centerY == imageView.superview!.centerY
            imageView.left == imageView.superview!.left + 20
        }
        
        self.imageView = imageView
        
        field.styleAsLabel()
        field.font = NSFont.systemFont(ofSize: 14, weight: NSFontWeightMedium)
        addSubview(field)
        
        constrain(field, imageView) { field, image in
            field.left == image.right + 8
            field.centerY == field.superview!.centerY
        }
        
        
        update()
    }
    
    var color: NSColor {
        switch type {
        case .today:
            return NSColor(hexString: "3D4AC6")!
        case .next:
            return NSColor(hexString: "039A9F")!
        }
    }
    
    var icon: NSImage {
        switch type {
        case .today:
            return #imageLiteral(resourceName: "TodayIcon")
        case .next:
            return #imageLiteral(resourceName: "NextIcon")
        }
    }
    
    func update() {
        imageView?.image = icon.tintedImageWithColor(color: color)
        field.textColor = color
    }
    
    

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
}
