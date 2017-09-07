//
//  DayHeaderView.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 9/6/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Cocoa
import Cartography

class DayHeaderView: NSView {

    var date = Date() { didSet { update() } }


    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setup()
    }

    let starView = NSImageView(image: #imageLiteral(resourceName: "TodayIcon").tintedImageWithColor(color: Stylesheet.primaryColor))

    let primaryTextColor = NSColor(hex: "b1b3b8")
    let secondaryTextColor = NSColor(hex: "d3d4d7")

    let primaryLabel = NSTextField(labelWithString: "")
    let secondaryLabel = NSTextField(labelWithString: "")

    func setup() {
        primaryLabel.font = NSFont.systemFont(ofSize: 14.0, weight: NSFontWeightRegular)
        primaryLabel.textColor = primaryTextColor

        let primaryStack = NSStackView(views: [starView, primaryLabel])
        primaryStack.orientation = .horizontal
        primaryStack.spacing = 4.0

        secondaryLabel.font = NSFont.systemFont(ofSize: 14.0, weight: NSFontWeightRegular)
        secondaryLabel.textColor = secondaryTextColor

        let spacer = NSView()

        let stack = NSStackView(views: [primaryStack, spacer, secondaryLabel])
        stack.orientation = .horizontal

        include(stack, insets: EdgeInsets(top: 0, left: 2.0, bottom: 0, right: 2.0))
    }

    func update() {
        primaryLabel.stringValue = date.string(custom: "E")
        secondaryLabel.stringValue = date.string(custom: "d")

        if date.isToday {
            primaryLabel.font = NSFont.systemFont(ofSize: 14.0, weight: NSFontWeightMedium)
            primaryLabel.textColor = Stylesheet.primaryColor
            secondaryLabel.textColor = Stylesheet.primaryColor
            starView.isHidden = false
        } else {
            primaryLabel.font = NSFont.systemFont(ofSize: 14.0, weight: NSFontWeightRegular)
            primaryLabel.textColor = primaryTextColor
            secondaryLabel.textColor = secondaryTextColor
            starView.isHidden = true

        }
    }
    
}
