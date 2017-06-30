//
//  TaskTitleTableCellView.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 4/26/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit
import ReactiveSwift
import NiceKit
import Cartography
import Lottie

class TaskTitleTableCellView: EditableTableCellView {
    var task = MutableProperty<Task?>(nil)
    
    let checkContainer = NSView()
    let checkAnim = LOTAnimationView(name: "check_fixed")!
    
    var wantsHighlightPlanned = true
    
    var controller: TasksViewController?
    
    var onTabOut: (() -> ())?
    
    let textColor = NSColor(hexString: "2F3232")
    let finishedTextColor = NSColor(hexString: "C2C9D0")
    let finishedOpacity: CGFloat = 0.25
    
    let leftMargin: CGFloat = 20.0
    let fieldLeftMargin: CGFloat = 44.0
    
    var fieldLeftConstraint: NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        wantsLayer = true
        
        setupTextField()
        
        setupCheck()

        setupConfigRow()
        
        setupBindings()
        
//        self.layer = CALayer()
//        self.wantsLayer = true
//        layer?.backgroundColor = NSColor.white.cgColor
//        layer?.cornerRadius = 4.0
    }
    
    func setupTextField() {
        // Text field
        
        let field = NSTextField()
        field.isBordered = false
        field.isSelectable = false
        field.isEditable = false
        field.font = NSFont.systemFont(ofSize: 14)
        field.drawsBackground = false
        field.backgroundColor = NSColor.clear
        field.focusRingType = .none
        addSubview(field)
        
        constrain(field) { field in
            field.top == field.superview!.top + 8
            field.bottom == field.superview!.bottom - 8
            field.left == field.superview!.left + fieldLeftMargin
            field.right == field.superview!.right - 8
        }
        
        self.textField = field
    }
    
    
    func setupCheck() {
        
        addSubview(checkContainer)
        
        constrain(checkContainer) { view in
            view.left == view.superview!.left + leftMargin
            view.width == 20
            view.height == 20
//            view.centerY == view.superview!.centerY + 1
            view.top == view.superview!.top + 8
        }
        
        // 02 Check animation
        checkAnim.contentMode = .scaleToFill
        
        checkContainer.addSubview(checkAnim)
        constrain(checkAnim) { check in
            check.center == check.superview!.center
            
            check.width == 800 * 0.2
            check.height == 600 * 0.2
        }
        
        setUnfinished()
        
        
        // 03 Gesture recognizer
        
        let recog = NiceClickGestureRecognizer(target: self, action: #selector(TaskTitleTableCellView.toggleFinished(_:)))
        
        checkContainer.addGestureRecognizer(recog)
    }

    let configRow = NSStackView()

    func setupConfigRow() {
        let projectLabel = NSTextField.label()
        projectLabel.stringValue = "Project:"
        projectLabel.textColor = NSColor(hexString: "ABB5C0")!
        projectLabel.font = NSFont.systemFont(ofSize: 13)

        configRow.orientation = .horizontal
        configRow.setViews([projectLabel], in: .leading)

        configRow.wantsLayer = true
        configRow.layer?.opacity = 0

        let anim = CABasicAnimation(keyPath: "opacity")
        anim.duration = 0.25

        configRow.layer?.actions = [
            "opacity": anim
        ]
        
//        configRow.alphaValue = 0

        addSubview(configRow)

        constrain(configRow) { row in
            row.bottom == row.superview!.bottom - 8
            row.left == row.superview!.left + 20
            row.right == row.superview!.right - 20
            row.height == 20
        }
    }
    
    func setUnfinished() {
        checkAnim.animationProgress = 0
    }
    
    func setFinished() {
        checkAnim.animationProgress = 1
    }
    
    @IBAction func toggleFinished(_ sender: Any) {
        guard let task = self.task.value else { return }
        
        if checkAnim.isAnimationPlaying {
            return
        }
        
        if !task.isFinished {
            self.textField?.animator().alphaValue = finishedOpacity
            checkAnim.play(completion: { (_) in
                task.isFinished = true
            })
        } else {
            task.isFinished = false
        }
    }
    
    func setupBindings() {
        guard let field = self.textField else { assertionFailure(); return }
        
        let isFinished = task.producer.pick({ $0.reactive.isFinished.producer })
        //        let isPlanned = task.producer.pick({ $0.reactive.isPlanned.producer })
        //        let project = task.producer.pick({ $0.reactive.project.producer })
        
        isFinished.producer.startWithValues { finished in
            let finished = finished ?? false
            finished ? self.setFinished() : self.setUnfinished()
//            field.textColor = finished ? self.finishedTextColor : self.textColor
            field.alphaValue = 1
        }
        
        let project = task.producer.pick({ $0.reactive.project.producer })
        let title = task.producer.pick({ $0.reactive.title.producer }).map { $0 ?? "" }
        
        let attributedTitle = SignalProducer.combineLatest(title.producer, project.producer, isFinished.producer).map { title, project, isFinished -> NSAttributedString in
            
            return self.createAttributedString(forTitle: title, project: project, isFinished: isFinished ?? false)
        }
        
        
        field.reactive.attributedStringValue <~ attributedTitle
    }
    
    func createAttributedString(forTitle title: String, project: Project?, isFinished: Bool) -> NSAttributedString {
        let projectName = project?.name ?? ""
        let projectColor = Palette.decode(colorName: project?.color) ?? NSColor(hexString: Stylesheet.primaryColor)!
        
        let resultAttr = NSMutableAttributedString()
        
        let titleAttr = NSMutableAttributedString(string: title)
        
        titleAttr.textColor = isFinished ? self.finishedTextColor : self.textColor
        
        resultAttr += titleAttr
        
        if projectName == "" {
            return resultAttr
        }
        
        let spacer = NSMutableAttributedString(string: "  –  ")
        spacer.textColor = self.finishedTextColor
        
        resultAttr += spacer
        
        let projectAttr = NSMutableAttributedString(string: projectName)
        
        if isFinished {
            projectAttr.textColor = self.finishedTextColor
        } else {
            projectAttr.textColor = projectColor
        }
        
        projectAttr.font = NSFont.systemFont(ofSize: 12)
        
        resultAttr += projectAttr
        
        return resultAttr
    }
    
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        super.controlTextDidEndEditing(obj)
        
        if let mov = obj.userInfo?["NSTextMovement"] as? Int,
            mov == NSTabTextMovement {
            
            DispatchQueue.main.async {
                self.onTabOut?()
            }
        }
    }
    
    /*
    override func controlTextDidChange(_ obj: Notification) {
        super.controlTextDidChange(obj)
        controller?.updateHeight(cellView: self)
    }
     */
    
    override func startEditing() {
        let task = self.task.value

        isEditing = true

        rowView?.isEditing = true
        
        controller?.updateHeight(cellView: self, animated: true) {
            self.textField?.stringValue = task?.title ?? ""

            super.startEditing()

            self.setEditingLayout()
        }
    }
    
    override func finishEditing() {
        guard let field = textField else { assertionFailure(); return }
        let task = self.task.value
        
        field.resignFirstResponder()
        field.isEditable = false
        
        isEditing = false

        configRow.layer?.opacity = 0

        controller?.updateHeight(cellView: self, animated: true) {
            self.rowView?.isEditing = false
            (self.outlineView as? EditableOutlineView)?.isEditing = false
            
            self.setRegularLayout()
            
            let value = field.stringValue
            task?.title = value
        }
        
    }

    func setEditingLayout() {
//        configRow.animator().alphaValue = 1
        configRow.layer?.opacity = 1

    }
    
    func setRegularLayout() {

    }
    

    
    func animateLayoutChanges(duration: Double) {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            context.allowsImplicitAnimation = true
            self.layoutSubtreeIfNeeded()
        }, completionHandler: nil)
    }
}
