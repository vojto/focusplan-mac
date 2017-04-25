//
//  MainWindow.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 4/25/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Cocoa

class MainWindow: NSWindow {
    @IBOutlet weak var secondaryView: NSView!
    @IBOutlet weak var mainView: NSView!
    
    let projectsController = ProjectsViewController(nibName: "ProjectsViewController", bundle: nil)!
    
    override func awakeFromNib() {
        Swift.print("Main window just woke up!")
        
    }
}
