//
//  BorderView.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 9/6/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Cocoa
import Cartography

class BorderView: NSBox {

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        boxType = .custom
        borderColor = Stylesheet.secondaryBorder
        borderWidth = 1.0
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bottom(_ view: NSView) {
        view.addSubview(self)

        constrain(self) { box in
            box.left == box.superview!.left
            box.right == box.superview!.right
            box.bottom == box.superview!.bottom
            box.height == 1
        }
    }
}

