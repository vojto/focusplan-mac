//
//  CalendarHeaderView.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 9/5/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Cocoa

class CalendarHeaderView: NSView {

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setup()
    }

    func setup() {
        Swift.print("setting up calendar header view")

        let label = HeaderLabel(text: "This week")
        label.addToHeaderRow(view: self)
        
    }
    
}
