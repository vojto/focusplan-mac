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
import NiceData


class TimerViewController: NSViewController {
    lazy var state = TimerState.instance
    
    
    @IBOutlet weak var toggleButton: NSSegmentedControl!
    @IBOutlet weak var startButton: NSButton?
    @IBOutlet weak var stopButton: NSButton?
    
    @IBOutlet weak var toggleMenu: NSMenu!
    
    
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var projectSection: NSView!
    @IBOutlet weak var projectLabel: NSTextField!
    @IBOutlet weak var projectColor: ProjectColorView!
    @IBOutlet weak var taskLabel: NSTextField!
    
    
    var timer: Timer?
    var currentTime = MutableProperty<Date>(Date())
    
    override func awakeFromNib() {
        statusLabel.font = NSFont.systemFont(ofSize: 11, weight: NSFontWeightMedium).monospaced()
        
        startUIRefreshTimer()
        
        let isTaskSelected = state.selectedTask.producer.map { $0 != nil }
        let isRunning = state.isRunning.producer
        
//        toggleButton.setMenu(toggleMenu, forSegment: 1)
        
        toggleButton.reactive.isEnabled <~ SignalProducer.combineLatest(
            isTaskSelected,
            isRunning
        ).map { selected, running -> Bool in
            return !(!running && !selected)
        }
        
        isRunning.startWithValues { running in
            if running {
                self.toggleButton.setImage(#imageLiteral(resourceName: "StopTemplate"), forSegment: 0)
            } else {
                self.toggleButton.setImage(#imageLiteral(resourceName: "StartTemplate"), forSegment: 0)
            }
        }
        

        let status = SignalProducer.combineLatest(state.isRunning.producer, currentTime.producer).map { running, date -> String in
            if running,
                let startedAt = self.state.generalLane.runningSince.value as Date? {
                let time = date.timeIntervalSince(startedAt)
                
                return Formatting.format(timeInterval: time)
            } else {
                return "No timer running."
            }
        }
        
        statusLabel.reactive.stringValue <~ status
        
        projectSection.reactive.isHidden <~ state.isRunning.map({ !$0 })
        projectLabel.reactive.stringValue <~ state.runningProject.producer.pick({ $0.reactive.name.producer }).map({ $0 ?? "" })
        projectColor.project <~ state.runningProject
        
        taskLabel.reactive.stringValue <~ state.runningTask.producer.pick({ $0.reactive.title.producer }).map({ $0 ?? "" })
        

        
    }
    
    @IBAction func toggleButtonClicked(_ sender: Any) {
        let index = toggleButton.selectedSegment
        
        if index == 0 {
            toggleTimer()
        } else if index == 1 {
            let size = toggleButton.frame.size
            
            toggleMenu.popUp(positioning: nil, at: NSPoint(x: size.width - 16, y: size.height), in: toggleButton)
        }
    }
    
    func toggleTimer() {
        if state.isRunning.value {
            state.stop()
        } else {
            startSimple(self)
        }
    }
    
    @IBAction func startSimple(_ sender: Any) {
        state.start()
        startUIRefreshTimer()
    }
    
    
    
    func startUIRefreshTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.currentTime.value = Date()
        })
    }
    
    func resetUIRefreshTimer() {
        timer?.invalidate()
        timer = nil
        
        startUIRefreshTimer()
    }
    
}
