//
//  TimerViewController.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/1/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit
import ReactiveSwift

class TimerViewController: NSViewController {
    let selectedTask = MutableProperty<Task?>(nil)
    @IBOutlet weak var startButton: NSButton!
    
    override func awakeFromNib() {
        selectedTask.producer.startWithValues { task in
            if task == nil {
                self.startButton.isEnabled = false
            } else {
                self.startButton.isEnabled = true
            }
            
        }
    }
}
