//
//  ScriptingManager.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 12/05/2017.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit

class ScriptingManager {
    
    var allScriptNames = [
        "json",
        "ReadOmnifocus"
    ]
    
    var script: NSAppleScript!
    
    var fileManager: FileManager { return FileManager.default }
    
    func installScripts() {
        let scripts = selectScriptsThatNeedInstalling()
        
        if scripts.count == 0  {
            return
        }
        
        requestPermissionToInstallScripts {
            for script in scripts {
                self.installScript(named: script)
            }
        }
    }
    
    func selectScriptsThatNeedInstalling() -> [String] {
        // Take each script name, check if it exists in destination
        // and compare hashes to see if it's the latest version.
        
        
        var scriptsNotInstalledYet = [String]()
        
        for scriptName in allScriptNames {
            if !checkIfScriptIsInstalled(named: scriptName) {
                scriptsNotInstalledYet.append(scriptName)
            }
        }
        
        return scriptsNotInstalledYet
    }
    
    func checkIfScriptIsInstalled(named scriptName: String) -> Bool {
        guard let installedURL = scriptInstalledURL(named: scriptName) else { return false }
        guard let bundleURL = scriptBundleURL(named: scriptName) else { return false }
        
        let exists = fileManager.fileExists(atPath: installedURL.relativePath)
        
        if !exists {
            return false
        }
        
        guard let existingData = try? Data(contentsOf: installedURL) else { return false }
        guard let bundleData = try? Data(contentsOf: bundleURL) else { return false }
        
        if existingData == bundleData {
            return true
        } else {
            return false
        }
    }
    
    func requestPermissionToInstallScripts(callback: @escaping (() -> ())) {
        guard let scriptsURL = self.scriptsURL else { return }
        
        let openPanel = NSOpenPanel()
        openPanel.directoryURL = scriptsURL
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        
        openPanel.prompt = "Select Script Folder"
        openPanel.message = "Please select the User > Library > Application Scripts > tech.median.FocusPlan folder"
        
        openPanel.begin { result in
            if result == NSFileHandlingPanelOKButton {
                let selectedURL = openPanel.url
                
                if selectedURL == scriptsURL {
                    callback()
                } else {
                    Swift.print("User selected wrong folder...")
                }
            } else {
                Swift.print("User cancelled...")
            }
            
        }
    }
    
    func installScript(named name: String) {
        guard let from = scriptBundleURL(named: name) else { return }
        guard let to = scriptInstalledURL(named: name) else { return }
        
        if fileManager.fileExists(atPath: to.relativePath) {
            try? fileManager.removeItem(at: to)
        }
        
        try? fileManager.copyItem(at: from, to: to)
    }
    
    func scriptBundleURL(named name: String) -> URL? {
        return Bundle.main.url(forResource: name, withExtension: "scpt")
    }
    
    func scriptInstalledURL(named name: String) -> URL? {
        guard let scriptsURL = self.scriptsURL else { return nil }
        

        return scriptsURL.appendingPathComponent(name).appendingPathExtension("scpt")
        
    }
    
    var scriptsURL: URL? {
        return try? fileManager.url(for: .applicationScriptsDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
    
    func importOmniFocus() {
        // Just try playing with the script
        
//        let url = Bundle.main.url(forResource: "ReadOmnifocus", withExtension: "scpt")!
        guard let url = scriptInstalledURL(named: "ReadOmnifocus") else { return }
        
        guard let task = try? NSUserAppleScriptTask(url: url) else { return }
        
        task.execute(withAppleEvent: nil) { (result, error) in
            Swift.print("Error: \(error)")
            Swift.print("Result: \(result)")
            
            let str = result?.stringValue
            
            Swift.print("Result string: \(str)")
        }
        
        
        /*
//        guard let script = NSAppleScript(contentsOf: url, error: nil) else { return }
        
        Swift.print("Running script at: \(url)")
        
        var err: NSDictionary?
        let result = script.executeAndReturnError(&err)
        let str = result.stringValue
        
        Swift.print("Error: \(err)")
        Swift.print("Result: \(str)")
        */
        
        
    }
    
    
}
