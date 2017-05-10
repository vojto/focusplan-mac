//
//  MenubarController.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/10/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit
import ReactiveSwift

class MenubarController {
    var statusItem: NSStatusItem!
    var menu: NSMenu!
    
    lazy var now = timer(interval: .seconds(1), on: QueueScheduler.main)
    
    func setup() {
        Swift.print("Setting up the menubar controller!")
        
        self.menu = createMenu()

        self.statusItem = createStatusItem()
        
        now.startWithValues { value in
            Swift.print("Time updated to: \(value)")
        }
    }
    
    func createStatusItem() -> NSStatusItem {
        let item = NSStatusBar.system().statusItem(withLength: 50)
        
        //        item.button = NSButton(title: "serus", target: nil, action: "")
        
        item.button?.image = #imageLiteral(resourceName: "Paradicka")
        item.button?.title = "bazinga"
        item.button?.imagePosition = .imageLeading
        
        item.menu = self.menu
        
        return item
    }
    
    func createMenu() -> NSMenu {
        
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "serus", action: nil, keyEquivalent: ""))
        
        return menu
    }
    

}
