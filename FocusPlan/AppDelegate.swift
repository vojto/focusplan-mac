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
import NiceData
import Fabric
import Crashlytics

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var mainWindow: MainWindow!
    @IBOutlet weak var timerWindow: NSWindow!
    
    static var instance: AppDelegate?
    
    let expirationDate = MutableProperty<Date?>(nil)
    
    let menubarController = MenubarController()
    
    lazy var preferencesController: PreferencesController = PreferencesController(windowNibName: "PreferencesController")

    static let allProjectsObserver: ReactiveObserver<Project> = {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Project")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return ReactiveObserver<Project>(context: AppDelegate.viewContext, request: request)
    }()
    
    override init() {
        super.init()
        
        AppDelegate.instance = self
    }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        let defaults = UserDefaults.standard
        let preferences: [String: Any] = [
            PreferencesKeys.wantsPomodoro: true,
            PreferencesKeys.pomodoroMinutes: 25,
            PreferencesKeys.shortBreakMinutes: 5,
            PreferencesKeys.longBreakMinutes: 15,
            PreferencesKeys.longBreakEach: 4,
            "NSApplicationCrashOnExceptions": true
        ]
        
        defaults.register(defaults: preferences)
        
        checkTrial()
    }

    
    
    let scripting = ScriptingManager()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        Fabric.with([Answers.self, Crashlytics.self])
        
        Answers.logCustomEvent(withName: "launch", customAttributes: nil)
        
        

//        BITHockeyManager.shared().configure(withIdentifier: "adb84588f78d456c9cb6fe62e76b7481")
//        // Do some additional configuration if needed here
//        BITHockeyManager.shared().start()

        
        setupAutosave()
        
        setupTimerWindow()
        
        menubarController.setup()
        
        setupCloudMerging()
        
        Swift.print("Finished launching!")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        TimerState.instance.stop()
        try? viewContext.save()
    }
    
    func showMainWindow() {
        NSApp.activate(ignoringOtherApps: true)
        mainWindow.makeKeyAndOrderFront(self)
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        mainWindow.makeKeyAndOrderFront(self)
        
        return true
    }
    
    
    // MARK: - Core Data stack
    // ------------------------------------------------------------------------
    
//    lazy var persistentContainer: NSPersistentContainer = {
//        let container = NSPersistentContainer(name: "FocusPlan")
//        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//            if let error = error {
//                fatalError("Unresolved error \(error)")
//            }
//        })
//        
//        container.viewContext.undoManager = UndoManager()
//        
//        return container
//    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "FocusPlan", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "kalafun.asdfasfasdf" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("FocusPlan.sqlite")
        
        let storeOptions: [String: Any] = [
//            NSPersistentStoreUbiquitousContentNameKey: "FocusPlanStore",
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true
//            NSPersistentStoreUbiquitousContentURLKey: "Path/",
//            NSPersistentStoreUbiquitousPeerTokenOption: "foo"
        ]
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: storeOptions)
        } catch let error as NSError{
            print("Error adding persistentstore to coordinator with error: \(error.localizedDescription)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var viewContext: NSManagedObjectContext = {

        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        
        managedObjectContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType )

        
        managedObjectContext.undoManager = UndoManager()
        
        return managedObjectContext
    }()
    
    static var viewContext: NSManagedObjectContext {
        return AppDelegate.instance!.viewContext
    }
    
    func setupCloudMerging() {
        let notif = NotificationCenter.default.reactive.notifications(forName: NSNotification.Name.NSPersistentStoreDidImportUbiquitousContentChanges)
        notif.observeValues { notif in
            self.viewContext.mergeChanges(fromContextDidSave: notif)
        }
    }
    
    
    @IBAction func saveAction(_ sender: AnyObject?) {
        let context = viewContext
        
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

    
    public static var undoManager: UndoManager {
        return viewContext.undoManager!
    }
    
    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        return viewContext.undoManager
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplicationTerminateReply {
        let context = viewContext
        
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
    
    // MARK: - Timer window
    // ------------------------------------------------------------------------
    
    func setupTimerWindow() {
        timerWindow.isMovableByWindowBackground = true
    }
    
    func toggleTimerWindow() {
        if timerWindow.isVisible {
            timerWindow.close()
        } else {
            timerWindow.orderFront(self)
        }
    }
    
    // MARK: - Preferences window
    // ------------------------------------------------------------------------
    
    func showPreferences() {
        preferencesController.showWindow(self)
    }
    
    @IBAction func preferencesAction(_ sender: Any) {
        showPreferences()
    }
    
    // MARK: - Importing
    // ------------------------------------------------------------------------
    
    func importFromOmnifocus() {
        if !scripting.allScriptsInstalled {
            requestScriptsInstallation()
        } else {
            scripting.importOmniFocus()
        }
    }
    
    func requestScriptsInstallation() {
        let alert = NSAlert()
        
        alert.messageText = "Download importing package"
        alert.informativeText = "For your security, the importing package needs to be downloaded and installed separately. It only takes a few seconds.\n\nCome back here once you've installed the package."
        alert.icon = nil
        
        alert.alertStyle = .warning
        
        alert.addButton(withTitle: "Download package")
        alert.addButton(withTitle: "Cancel")
        
        let result = alert.runModal()
        
        if result != NSAlertFirstButtonReturn {
            return
        }
        
        let workspace = NSWorkspace.shared()
        let url = URL(string: "http://focuslist.co/plan/omnifocus.html")!
        
        workspace.open(url)
    }
}
