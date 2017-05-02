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
    
    @IBOutlet weak var startButton: NSButton!
    @IBOutlet weak var stopButton: NSButton!
    
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var projectSection: NSView!
    @IBOutlet weak var projectLabel: NSTextField!
    @IBOutlet weak var projectColor: ProjectColorView!
    @IBOutlet weak var taskLabel: NSTextField!
    
    
    var timer: Timer?
    var currentTime = MutableProperty<Date>(Date())
    
    override func awakeFromNib() {
        statusLabel.font = NSFont.systemFont(ofSize: 11, weight: NSFontWeightMedium).monospaced()
        
        startTimer()
        
        startButton.reactive.isEnabled <~ state.selectedTask.producer.map { $0 != nil }
        
        startButton.reactive.isHidden <~ state.isRunning
        stopButton.reactive.isHidden <~ state.isRunning.map { !$0 }
        
        let status = SignalProducer.combineLatest(state.isRunning.producer, currentTime.producer).map { running, date -> String in
            if running,
                let startedAt = self.state.currentEntry.value?.startedAt as Date? {
                var time = date.timeIntervalSince(startedAt)
                
                if time < 0 {
                    time = 0
                }
                
                let minutes = Int(floor(time / 60))
                
                let seconds = Int((time - Double(minutes * 60)))
                
                let formattedTime = NSString(format: "%02d:%02d", minutes, seconds)
                
                return "\(formattedTime)"
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
    
    @IBAction func startTimer(_ sender: Any) {
        state.start()
        resetTimer()
    }
    
    @IBAction func stopTimer(_ sender: Any) {
        state.stop()
    }
    
    func startTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.currentTime.value = Date()
        })
    }
    
    func resetTimer() {
        timer?.invalidate()
        timer = nil
        
        startTimer()
    }
    
}
