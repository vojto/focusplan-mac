//
//  AppDelegate+TrialChecking.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/24/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import KeychainAccess
import SwiftDate
import AppKit

extension AppDelegate {
    func checkTrial() {
        if !Config.isTrial {
            return
        }
        
        let trialPeriod = 7.days
        
        let keychain = Keychain(service: "com.apple.account.IdentityServices.access-key")
        let key = "AppleIdMatchedUser"
        
        var value: String?
        
        do {
            value = try keychain.get(key)
        } catch {
            // Failed reading value fro keychain
        }
        
        if let value = value {
            // Trial value already installed, check if it's valid
            
            guard let data = Data(base64Encoded: value) else { return exitWithExpirationNotice() }
            guard let obj = NSKeyedUnarchiver.unarchiveObject(with: data) else { return exitWithExpirationNotice() }
            guard let date = obj as? Date else { return exitWithExpirationNotice() }
            
            // check if it's expired
            let expirationDate = date + trialPeriod
            
            self.expirationDate.value = expirationDate
            
            if expirationDate.isInPast {
                return exitWithExpirationNotice()
            }
            
        } else {
            let date = Date()
            let data = NSKeyedArchiver.archivedData(withRootObject: date)
            let value = data.base64EncodedString()
            
            expirationDate.value = date + trialPeriod
            
            try? keychain.set(value, key: key)
        }
    }
    
    func exitWithExpirationNotice() {
        let alert = NSAlert()
        
        alert.messageText = "Your trial has expired."
        alert.informativeText = "Would you like to head over to the App Store and purchase it?"
        alert.icon = nil
        
        alert.alertStyle = .warning
        
        alert.addButton(withTitle: "Open App Store")
        alert.addButton(withTitle: "Cancel")
        
        let result = alert.runModal()
        
        if result == NSAlertFirstButtonReturn {
            openAppStore(event: "trial-expired")
        }
        
        NSApp.terminate(nil)
    }
    
    func openAppStore(event: String) {
        let url = URL(string: "https://geo.itunes.apple.com/us/app/focusplan/id1236753353?mt=12&at=1010l9IS&ct=app-\(event)")!
        
        let ws = NSWorkspace.shared()
        ws.open(url)
    }
}
