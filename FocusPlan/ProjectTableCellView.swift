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

enum ColorName: String {
    case blue
    case purple
    case steel
    case magenta
    case red
    case yellow
    case green
    case teal
}

typealias Color = (name: ColorName, area0: String, area1: String, area2: String, line1: String, line0: String)

let colors: [Color] = [
    (name: .blue, area0: "2067CA", area1: "5085E5", area2: "93B0FC", line1: "2081FE", line0: "1C4F91"),
    (name: .purple, area0: "9060D5", area1: "B091F0", area2: "CFBDF5", line1: "9A59F7", line0: "6F38BE"),
    (name: .steel, area0: "5B6F87", area1: "7289A4", area2: "97AEC9", line1: "556D8B", line0: "384B63"),
    (name: .magenta, area0: "D265CF", area1: "E691F0", area2: "F5BDF4", line1: "F732CC", line0: "DB16B0"),
    (name: .red, area0: "DC5C53", area1: "E98E87", area2: "F1BEBA", line1: "EA2E21", line0: "B90C00"),
    (name: .yellow, area0: "E4942A", area1: "EFB566", area2: "F4D1A4", line1: "F69C25", line0: "C26F00"),
    (name: .green, area0: "3C9578", area1: "64B49A", area2: "93D8C2", line1: "459D60", line0: "107931"),
    (name: .teal, area0: "2CA2A7", area1: "4CC2C7", area2: "85DEE2", line1: "00B9C0", line0: "008085")
]

class ProjectTableCellView: NSTableCellView {
    let project = MutableProperty<Project?>(nil)
    
    @IBOutlet var colorPicker: ColorPicker!
    
    override func awakeFromNib() {
        colorPicker.colors = colors.map { NSColor(hexString: $0.area0)! }
        colorPicker.selectedColor = colorPicker.colors.first
        colorPicker.wantsAuto = false
        colorPicker.onChange = { nsColor in
            guard let color = colors.filter({ NSColor(hexString: $0.area0)! == nsColor }).first else { return }
            self.project.value?.color = color.name.rawValue
        }
        
        let color = project.producer.pick { $0.reactive.color }
        color.startWithValues { colorName in
            guard let color = colors.filter({ $0.name.rawValue == colorName }).first else { return }
            let nsColor = NSColor(hexString: color.area0)
            self.colorPicker.selectedColor = nsColor
        }
        
    
    }
}
