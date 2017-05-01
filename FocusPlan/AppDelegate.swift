//
//  AppDelegate.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 4/25/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Cocoa
import ReactiveSwift
import ReactiveCocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Fetch the project
        
        
        let context = AppDelegate.viewContext
        let request = NSFetchRequest<Project>(entityName: "Project")
        let results = try! context.fetch(request)
        
        if let project = results.first {
//            Swift.print("Tasks: \(project.tasks)")
            
            /*
            let task = NSEntityDescription.insertNewObject(forEntityName: "Task", into: context) as! Task
            task.title = "build this app in 2 weeks"
            task.text = "and be awesome while doing it"
            task.project = project
            task.estimatedMinutes = 4800    
            */
        }
        
        
        setupAutosave()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
    
    
    // MARK: - Core Data stack
    // ------------------------------------------------------------------------
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FocusPlan")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        })
        
        container.viewContext.undoManager = UndoManager()
        
        return container
    }()
    
    // MARK: Core Data Saving and Undo support
    
    
    @IBAction func saveAction(_ sender: AnyObject?) {
        let context = persistentContainer.viewContext
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
        }
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Customize this code block to include application-specific recovery steps.
                let nserror = error as NSError
                NSApplication.shared().presentError(nserror)
            }
        }
    }
    
    public static var viewContext: NSManagedObjectContext {
        let delegate = NSApplication.shared().delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }
    
    public static var undoManager: UndoManager {
        return viewContext.undoManager!
    }
    
    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        return persistentContainer.viewContext.undoManager
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplicationTerminateReply {
        let context = persistentContainer.viewContext
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        
        if !context.hasChanges {
            return .terminateNow
        }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            
            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(nserror)
            if (result) {
                return .terminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == NSAlertSecondButtonReturn {
                return .terminateCancel
            }
        }

        return .terminateNow
    }

    
    // MARK: - Autosave
    // ------------------------------------------------------------------------
    
    func setupAutosave() {
        let center = NotificationCenter.default
        
        let signal = center.reactive.notifications(forName: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: AppDelegate.viewContext)
        
        signal.throttle(2, on: QueueScheduler.main).observeValues { notification in
            self.handleMainContextChanged()
        }
    }
    
    func handleMainContextChanged() {
        let context = AppDelegate.viewContext
        
        context.processPendingChanges()
        context.undoManager?.disableUndoRegistration()
        
        try! context.save()
        
        context.processPendingChanges()
        context.undoManager?.enableUndoRegistration()
    }
}

