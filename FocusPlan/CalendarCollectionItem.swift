//
//  CalendarCollectionItem.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 4/28/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Cocoa

class CalendarCollectionItem: NSCollectionViewItem {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

        view.layer = CALayer()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor(hexString: "f1f7fd")?.cgColor
        view.layer?.borderColor = NSColor(hexString: "4A90E2")?.cgColor
        view.layer?.borderWidth = 0.5
        view.layer?.cornerRadius = 3.0
    }
    
}
