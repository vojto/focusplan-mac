//
//  AlertHelper.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/15/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation

//
//  AlertHelper.swift
//  Median
//
//  Created by Vojtech Rinik on 26/01/2017.
//  Copyright © 2017 Vojtech Rinik. All rights reserved.
//

import Foundation
import AppKit

class AlertHelper {
    public static func error(title: String, description: String) {
        show(title: title, description: description, style: .critical)
    }
    
    public static func info(title: String, description: String) {
        show(title: title, description: description, style: .informational)
    }
    
    public static func show(title: String, description: String, style: NSAlertStyle, wantsCancel: Bool = false) {
        let alert = NSAlert()
        
        alert.messageText = title
        alert.informativeText = description
        
        alert.alertStyle = style
        
        alert.addButton(withTitle: "OK")
        
        if wantsCancel {
            alert.addButton(withTitle: "Cancel")
        }
        
        alert.runModal()
    }

    
}
