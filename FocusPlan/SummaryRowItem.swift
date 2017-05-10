//
//  SummaryRowItem.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/10/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit

class SummaryRowItem: NSView {
    @IBOutlet weak var colorView: ProjectColorView!
    @IBOutlet weak var label: NSTextField!
    
    override func awakeFromNib() {
        colorView.alpha = 0.5
    }
}
