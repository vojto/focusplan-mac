//
//  ProjectColorView.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/1/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit
import Hue
import ReactiveSwift


class ProjectColorView: NSView {
    
    let project = MutableProperty<Project?>(nil)
    
    override func awakeFromNib() {
        layer = CALayer()
        wantsLayer = true
        
        let color = project.producer.pick({ $0.reactive.color })
        
        color.startWithValues { colorName in
            guard let color = Palette.decode(colorName: colorName) else { return }
            let borderColor = color.addHue(0, saturation: 0, brightness: -0.15, alpha: 0)
            
            self.layer?.backgroundColor = color.cgColor
            self.layer?.borderColor = borderColor.cgColor
        }
        
        layer?.borderWidth = 0.5
        
        updateCorner()
        
    }
    
    
    override var frame: NSRect {
        didSet {
            updateCorner()
        }
    }
    
    func updateCorner() {
        layer?.cornerRadius = frame.size.width / 2 + 0.5
    }

}
