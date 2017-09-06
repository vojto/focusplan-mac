//
//  CalendarHeaderView.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 9/5/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Cocoa
import Cartography

class CalendarHeaderView: NSView {

    var config: PlanConfig? {
        didSet {
            update()
        }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        setup()
    }

    let daysStack = NSStackView()

    func setup() {
        let label = HeaderLabel(text: "This week")
        label.addToHeaderRow(view: self)


        let border = BorderView()
        border.bottom(self)

        addSubview(daysStack)
        constrain(daysStack) { view in
            view.left == view.superview!.left + CalendarCollectionLayout.kWeeklySideMargin
            view.right == view.superview!.right - CalendarCollectionLayout.kWeeklySideMargin
            view.bottom == view.superview!.bottom
            view.height == 40.0
        }

        daysStack.orientation = .horizontal
        daysStack.distribution = .fillEqually

    }

    func update() {
        var views = [DayHeaderView]()
//
//        for day in config!.days {
//            let view = DayHeaderView()
//            views.append(view)
//        }
//
//        daysStack.setViews(views, in: .leading)

    }
    
}
