//
//  PreferencesController.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/12/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Cocoa
import ReactiveSwift

class PreferencesController: NSWindowController {
    @IBOutlet weak var pomodoroField: NSTextField!
    @IBOutlet weak var shortBreakField: NSTextField!
    @IBOutlet weak var longBreakField: NSTextField!
    @IBOutlet weak var longBreakEach: NSTextField!
    
    @IBOutlet weak var enabledButton: NSButton!
    
    override func windowDidLoad() {
        super.windowDidLoad()

        let defaults = UserDefaults.standard
        
        let format: ((Int) -> (String)) = { time in
            return Formatting.format(estimate: time)
        }
        
        
        // Enabled checkbox
        
        let wantsPomodoro = defaults.reactive.wantsPomodoro
        enabledButton.reactive.boolValue <~ wantsPomodoro
        enabledButton.reactive.boolValues.observeValues { wants in
            defaults.set(wants, forKey: PreferencesKeys.wantsPomodoro)
        }
        
        pomodoroField.reactive.stringValue <~ defaults.reactive.pomodoroMinutes.map(format)
        pomodoroField.reactive.isEnabled <~ wantsPomodoro
        
        shortBreakField.reactive.stringValue <~ defaults.reactive.shortBreakMinutes.map(format)
        shortBreakField.reactive.isEnabled <~ wantsPomodoro
        
        longBreakField.reactive.stringValue <~ defaults.reactive.longBreakMinutes.map(format)
        longBreakField.reactive.isEnabled <~ wantsPomodoro
        
        longBreakEach.reactive.stringValue <~ defaults.reactive.longBreakEach.map { String($0) }
        longBreakEach.reactive.isEnabled <~ wantsPomodoro
        
    
        pomodoroField.reactive.stringValues.observeValues { value in
            defaults.set(Formatting.parseMinutes(value: value), forKey: PreferencesKeys.pomodoroMinutes)
        }
        
        shortBreakField.reactive.stringValues.observeValues { value in
            defaults.set(Formatting.parseMinutes(value: value), forKey: PreferencesKeys.shortBreakMinutes)
        }
        
        longBreakField.reactive.stringValues.observeValues { value in
            defaults.set(Formatting.parseMinutes(value: value), forKey: PreferencesKeys.longBreakMinutes)
        }
        
        longBreakEach.reactive.stringValues.observeValues { value in
            defaults.set(Int(value), forKey: PreferencesKeys.longBreakEach)
        }
    }
    
}
