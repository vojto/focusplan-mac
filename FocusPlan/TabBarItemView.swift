//
//  TabBarItemView.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/11/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit

class TabBarItemView: NSView {
    
    @IBOutlet weak var button: NSButton!
    
    var item: TabBarItem! {
        didSet {
            update()
        }
    }
    
    var isActive: Bool = false {
        didSet {
            update()
        }
    }
    
    func update() {
        let attr = NSMutableAttributedString(string: item.label)
        attr.addAttribute(NSForegroundColorAttributeName, value: textColor)
        attr.addAttribute(NSFontAttributeName, value: NSFont.systemFont(ofSize: 11, weight: NSFontWeightMedium))
        
        button.attributedTitle = attr
        button.image = item.image.tintedImageWithColor(color: color)
    }
    
    
    var color: NSColor {
        return isActive ? NSColor(hexString: "4990E2")! : NSColor(hexString: "B2B2B2")!
    }
    
    var textColor: NSColor {
        return isActive ? NSColor(hexString: "4990E2")! : NSColor(hexString: "9B9B9B")!
    }
    
    
    
}
