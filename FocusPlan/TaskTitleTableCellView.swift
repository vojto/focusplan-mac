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
    
    let estimateField = NSTextField.label()

    let configRow = NSStackView()
    let configProjectField = ProjectField()
    let configEstimateField = NiceField()
    
    var wantsHighlightPlanned = true
    
    var controller: TasksViewController?
    
    var onTabOut: (() -> ())?
    
    let textColor = NSColor(hexString: "2F3232")
    let finishedTextColor = NSColor(hexString: "C2C9D0")
    let finishedOpacity: CGFloat = 0.25
    
    let leftMargin: CGFloat = 20.0
    let fieldLeftMargin: CGFloat = 44.0
    let configRowHeight: CGFloat = 24.0
    
    var fieldLeftConstraint: NSLayoutConstraint?
    var fieldEditingBottomConstraint: NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        wantsLayer = true
        
        setupTextField()
        
        setupEstimateField()

        setupConfigRow()
        setupConfigRowBindings()
        
        setupCheck()
        
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
        field.wantsLayer = true
        addSubview(field)
        
        constrain(field) { field in
            field.top == field.superview!.top + 8
            (field.bottom == field.superview!.bottom - 8) ~ LayoutPriority(750)
            self.fieldEditingBottomConstraint = ((field.bottom == field.superview!.bottom - 35) ~ LayoutPriority(1000))

            field.left == field.superview!.left + fieldLeftMargin
            field.right == field.superview!.right - 40
        }

        fieldEditingBottomConstraint?.isActive = false
        
        self.textField = field
    }
    
    func setupEstimateField() {
        estimateField.font = NSFont.systemFont(ofSize: 13, weight: NSFontWeightRegular)
        estimateField.textColor = NSColor(hexString: "9099A3")!
        
        addSubview(estimateField)
        constrain(estimateField) { estimate in
            estimate.right == estimate.superview!.right - 8
            estimate.centerY == estimate.superview!.centerY
        }
        
        
        let estimate = task.producer.pick { $0.reactive.estimatedMinutesFormatted }
        
        estimateField.reactive.stringValue <~ estimate.map({ $0 ?? "None" })
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


    func setupConfigRow() {
        let labelColor = NSColor(hexString: "ABB5C0")!
        let labelFont = NSFont.systemFont(ofSize: 12)

        let projectLabel = NSTextField.label()
        projectLabel.stringValue = "Project:"
        projectLabel.textColor = labelColor
        projectLabel.font = labelFont

        let estimateLabel = NSTextField.label()
        estimateLabel.stringValue = "Estimate:"
        estimateLabel.textColor = labelColor
        estimateLabel.font = labelFont

        configEstimateField.stringValue = "None"

        configRow.orientation = .horizontal
        configRow.setViews([
            projectLabel,
            configProjectField,
            estimateLabel,
            configEstimateField
        ], in: .leading)

        configRow.isHidden = true

        addSubview(configRow)

        constrain(configRow) { row in
            row.bottom == row.superview!.bottom - 8
            row.left == row.superview!.left + 20
            row.right == row.superview!.right - 20
            row.height == configRowHeight
        }
    }

    func setupConfigRowBindings() {
        // Bind estimate

        let estimate = task.producer.pick { $0.reactive.estimatedMinutesFormatted }

        estimate.producer.startWithValues { estimate in
            self.configEstimateField.stringValue = estimate ?? "None"
        }

        configEstimateField.onChange = { value in
            let task = self.task.value
            task?.setEstimate(fromString: value)
        }

        // Bind project

        let project = task.producer.pick { $0.reactive.project }

        project.producer.startWithValues { project in
            self.configProjectField.stringValue = project?.name ?? "None"
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

    override func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {

        if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
            self.forceFinishEditing()
        } else if commandSelector == #selector(NSResponder.insertNewline(_:)) {
            self.forceFinishEditing()
        } else if commandSelector == #selector(NSResponder.insertTab(_:)) {
            self.forceFinishEditing()
        } else {
            return super.control(control, textView: textView, doCommandBy: commandSelector)
        }

        return true

    }
    
    /*
    override func controlTextDidChange(_ obj: Notification) {
        super.controlTextDidChange(obj)
        controller?.updateHeight(cellView: self)
    }
     */
    
    override func startEditing() {
        startEditing(animated: true)
    }
    
    func startEditing(animated: Bool) {
        if isEditing {
            return
        }

        let task = self.task.value

        isEditing = true

        rowView?.isEditing = true
        
        estimateField.isHidden = true

        controller?.updateHeight(cellView: self, animated: true) {
            self.textField?.stringValue = task?.title ?? ""

            super.startEditing()

            self.setEditingLayout()
        }
    }
    
    override func finishEditing() {
        // Skip traditional finishing of editing, because finishing editing
        // for this type of cell is done in a customized way. (global NSEvent)

    }

    func forceFinishEditing() {
        guard let field = textField else { assertionFailure(); return }
        let task = self.task.value
        
        Swift.print("Here's the project: \(task?.project)")

        let newTitle = field.stringValue
//        field.stringValue = ""

//        field.resignFirstResponder()
        window?.makeFirstResponder(nil)
        field.isEditable = false
        field.isSelectable = false
        field.attributedStringValue = self.createAttributedString(forTitle: newTitle, project: task?.project, isFinished: task?.isFinished ?? false)

        isEditing = false

        configRow.isHidden = true

//        controller?.updateHeight(cellView: self, animated: true) {

            self.rowView?.isEditing = false
            (self.outlineView as? EditableOutlineView)?.editedCellView = nil

            self.setRegularLayout()

            task?.title = newTitle
//        }

        controller?.updateHeight(cellView: self, animated: false)
    }

    func setEditingLayout() {
        configRow.isHidden = false
        fieldEditingBottomConstraint?.isActive = true

    }
    
    func setRegularLayout() {
        fieldEditingBottomConstraint?.isActive = false
        estimateField.isHidden = false
    }
    

    
    func animateLayoutChanges(duration: Double) {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            context.allowsImplicitAnimation = true
            self.layoutSubtreeIfNeeded()
        }, completionHandler: nil)
    }
}
