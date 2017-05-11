//
//  ProjectTableCellView.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 4/26/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit
import NiceKit
import NiceUI
import ReactiveSwift
import NiceReactive


class ProjectTableCellView: EditableTableCellView {
    let project = MutableProperty<Project?>(nil)
    
    @IBOutlet var colorPicker: ColorPicker!
    
    override func awakeFromNib() {
        colorPicker.colors = Palette.colors.map { NSColor(hexString: $0.area0)! }
        colorPicker.selectedColor = colorPicker.colors.first
        colorPicker.wantsAuto = false
        colorPicker.onChange = { nsColor in
            guard let colorName = Palette.encode(color: nsColor) else { return }
            self.project.value?.color = colorName
        }
        
        let color = project.producer.pick { $0.reactive.color }
        color.startWithValues { colorName in
            guard let nsColor = Palette.decode(colorName: colorName) else { return }
            self.colorPicker.selectedColor = nsColor
        }
    }
}
