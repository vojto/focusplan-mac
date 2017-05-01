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

class TimerState {
    static let instance = TimerState()
    
    let runningTask = MutableProperty<Task?>(nil)
    let selectedTask = MutableProperty<Task?>(nil)
}

class TimerViewController: NSViewController {
    let state = TimerState.instance
    
    @IBOutlet weak var startButton: NSButton!
    
    override func awakeFromNib() {
        state.selectedTask.producer.startWithValues { task in
            if task == nil {
                self.startButton.isEnabled = false
            } else {
                self.startButton.isEnabled = true
            }
            
        }
    }
}
