//
//  TrialButtonViewController.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/24/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Cocoa
import ReactiveSwift
import ReactiveCocoa
import SwiftDate

class TrialButtonViewController: NSTitlebarAccessoryViewController {
    @IBOutlet weak var label: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let app = AppDelegate.instance else { return }
        

        label.reactive.stringValue <~ app.expirationDate.map { date in
            guard let date = date else { return "" }
            
            let diff = date.startOf(component: .day) - Date().startOf(component: .day)
            var days = Int(diff / (3600 * 24))
            
            if days < 0 {
                days = 0
            }
            
            return "\(days) days left in trial"
        }
        
    }
    
    @IBAction func openAppStore(_ sender: Any) {
        guard let app = AppDelegate.instance else { return }
        
        app.openAppStore(event: "buy-button")
    }
    
    
}
