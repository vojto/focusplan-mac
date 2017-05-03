//
//  CalendarSectionLabel.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/3/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit
import Cartography

class CalendarSectionLabel: NSView, NSCollectionViewElement {
    var label: NSTextField!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        self.label = NSTextField(labelWithString: "Label")
        label.font = NSFont.systemFont(ofSize: 12, weight: NSFontWeightMedium)
        label.textColor = NSColor.secondaryLabelColor
        addSubview(label)
        
        constrain(label) { view in
            view.center == view.superview!.center
        }
    }
    
    func apply(_ layoutAttributes: NSCollectionViewLayoutAttributes) {
        guard let index = layoutAttributes.indexPath?.item else { return }
        
        let day = Date().startOf(component: .weekOfYear).add(components: [.day: index])
        
        label.stringValue = day.string(custom: "E")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
