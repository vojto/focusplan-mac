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

    let headerLabel = HeaderLabel(text: "This week")

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
        setupHeader()
        setupBorder()
        setupDaysStack()
        setupButtons()
    }

    func setupHeader() {
        headerLabel.addToHeaderRow(view: self)
    }

    func setupBorder() {
        let border = BorderView()
        border.bottom(self)
    }

    func setupDaysStack() {
        addSubview(daysStack)
        constrain(daysStack) { view in
            view.left == view.superview!.left + CalendarCollectionLayout.kWeeklySideMargin
            view.right == view.superview!.right - CalendarCollectionLayout.kWeeklySideMargin
            view.bottom == view.superview!.bottom - 8.0
        }

        daysStack.orientation = .horizontal
        daysStack.distribution = .fillEqually
    }

    func setupButtons() {

        let prevImage = NSImage(named: NSImageNameGoLeftTemplate)!
        let nextImage = NSImage(named: NSImageNameGoRightTemplate)!

        let prevButton = NSButton(image: prevImage, target: nil, action: #selector(MainWindow.previousUnit))
        let todayButton = NSButton(title: "Today", target: nil, action: #selector(MainWindow.resetUnit))
        let nextButton = NSButton(image: nextImage, target: nil, action: #selector(MainWindow.nextUnit))

        let buttons = [prevButton, todayButton, nextButton]

        let stack = NSStackView(views: buttons)
        stack.orientation = .horizontal
        stack.spacing = 1.0

        addSubview(stack)

        constrain(stack) { buttons in
            buttons.right == buttons.superview!.right - 20.0
            buttons.bottom == buttons.superview!.bottom - 45.0
        }
    }

    func update() {
        var views = [DayHeaderView]()

        for day in config!.days {
            let view = DayHeaderView()
            view.date = day
            views.append(view)
        }

        daysStack.setViews(views, in: .leading)
    }

    func setTitle(_ title: String) {
        headerLabel.text = title
    }
    
}
