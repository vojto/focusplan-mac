//
//  CalendarViewController.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 4/28/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Cocoa
import ReactiveSwift
import SwiftDate

enum CalendarDecorationSection: Int {
    case hourLine = 0
    case sectionLine = 1
    case sectionLabel = 2
}

class CalendarViewController: NSViewController, NSCollectionViewDataSource, NSCollectionViewDelegate, NSPopoverDelegate {

    @IBOutlet var collectionView: CalendarCollectionView!
    let collectionLayout = CalendarCollectionLayout()
    
    @IBOutlet weak var summaryContainer: NSView!
    let summaryRowController = SummaryRowViewController()
    
    var editTaskController: EditTaskViewController?
    var editTaskPopover: NSPopover?
    
    var editTimerEntryController: EditTimerEntryController?
    var editTimerEntryPopover: NSPopover?
    
    var events = CalendarEventsCollection()
    
    let selectedEvents = MutableProperty<Set<CalendarEvent>>(Set())
    
    var onReorder: (() -> ())?
    var onCreate: ((_ plannedFor: Date?) -> ())?
    
    var scrollingPositions = [Int: CGFloat]()
    
    var config = PlanConfig.defaultConfig {
        willSet {
            saveScrollPosition()
        }
        
        didSet {
            reloadData()
            
            restoreScrollPosition()
        }
    }
    
    var selectedTasks: Set<Task> {
        var tasks = Set<Task>()
        
        for event in selectedEvents.value {
            if event.type == .task, let task = event.task {
                tasks.insert(task)
            }
        }
        
        return tasks
    }
    
    var selectedEntries: Set<TimerEntry> {
        var entries = Set<TimerEntry>()
        
        for event in selectedEvents.value {
            if event.type == .timerEntry, let entry = event.timerEntry {
                entries.insert(entry)
            }
        }
        
        return entries
    }
    
    
    // MARK: - Lifecycle
    // ------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.collectionViewLayout = collectionLayout
        collectionView.onDoubleClick = handleDoubleClick
        
        let nib = NSNib(nibNamed: "CalendarHourHeader", bundle: nil)
        collectionView.register(nib, forSupplementaryViewOfKind: kHourHeader, withIdentifier: kHourHeaderIdentifier)
        
        collectionLayout.register(CalendarTimeLine.self, forDecorationViewOfKind: kTimeLine)
        
        collectionLayout.register(CalendarSectionLine.self, forDecorationViewOfKind: kSectionLine)
        
        collectionLayout.register(CalendarSectionLabel.self, forDecorationViewOfKind: kSectionLabel)
        
        collectionView.register(forDraggedTypes: [NSStringPboardType])

        setupSelectionObserving()
        
        collectionView.scrollSignal.throttle(0.5, on: QueueScheduler.main).observeValues {
            self.view.window?.resetCursorRects()
        }

        summaryContainer.include(summaryRowController.view)
        
        DispatchQueue.main.async {
            self.restoreScrollPosition()
        }
    }
    
    func reloadData() {
        // TODO: Temporary hack to avoid reloading collection when popover
        // makes changes to data...
        if (editTaskPopover?.isShown ?? false) {
            return
        }
        
        if (editTimerEntryPopover?.isShown ?? false) {
            return
        }
        
        NSAnimationContext.current().duration = 0
        self.collectionView.reloadData()
    }
    
    // MARK: - Scrolling
    // ------------------------------------------------------------------------
    
    func saveScrollPosition() {
        if let scrollView = collectionView.enclosingScrollView {
            let rect = scrollView.documentVisibleRect
            
            scrollingPositions[config.scrollingPositionIdentifier] = rect.origin.y
        }
    }
    
    func restoreScrollPosition() {
        var initialPosition: CGFloat = 0
        
        if config.style == .hybrid {
            let time = Date().timeIntervalSinceStartOfDay
            initialPosition = max(0, collectionLayout.points(forTime: time) - 50)
        }
        
        if let scrollView = collectionView.enclosingScrollView {
            let position = scrollingPositions[config.scrollingPositionIdentifier] ?? initialPosition
            
//            Swift.print("🏀 set config, so scrolling down to \(position)")
            
            scrollView.contentView.scroll(to: NSPoint(x: 0, y: position))
            
        }
    }
    
    // MARK: - Feeding data to the collection view
    // ------------------------------------------------------------------------
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return config.dayCount
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = events.sections.at(section)?.count ?? 0
        
        return count
    }
    
    // MARK: - Making views
    // ------------------------------------------------------------------------
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: "CalendarCollectionItem", for: indexPath) as! CalendarCollectionItem
        
        item.onEdit = self.handleEdit
        
        item.event.value = events.at(indexPath: indexPath)
        
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> NSView {
        
        if kind == kHourHeader {
            let view = collectionView.makeSupplementaryView(ofKind: kind, withIdentifier: kHourHeaderIdentifier, for: indexPath) as! CalendarHourHeader
            
            view.textField.stringValue = collectionLayout.hourHeaderLabel(at: indexPath)
            
            return view
        } else if kind == kTimeLine {
            return NSView()
        } else {
            return collectionView.makeSupplementaryView(ofKind: kind, withIdentifier: "", for: indexPath)
        }
    }
    
    
    // MARK: - Accessing events
    // ------------------------------------------------------------------------

    func allIndexPaths() -> [IndexPath] {
        return events.allIndexPaths
    }
    
    func event(atIndexPath path: IndexPath) -> CalendarEvent? {
        return events.at(indexPath: path)
    }
    
    // MARK: - Drag and drop
    // ------------------------------------------------------------------------
    
    var draggedItem: NSCollectionViewItem?
    var draggedEvent: CalendarEvent?
    var draggedIndexPath: IndexPath?
    
    func collectionView(_ collectionView: NSCollectionView, canDragItemsAt indexPaths: Set<IndexPath>, with event: NSEvent) -> Bool {
        
        guard let path = indexPaths.first else { return false }
        let event = events.at(indexPath: path)
        
        return (event.type == .task)
    }
    
    func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt indexPath: IndexPath) -> NSPasteboardWriting? {
        
        let data = NSKeyedArchiver.archivedData(withRootObject: indexPath)
        return data.base64EncodedString() as NSString
    }
    
    func collectionView(_ collectionView: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo, proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionViewDropOperation>) -> NSDragOperation {

        let proposedDropIndexPath = proposedDropIndexPath.pointee as IndexPath
        
        if let draggedItem = draggedItem,
            let currentIndexPath = collectionView.indexPath(for: draggedItem),
            currentIndexPath != proposedDropIndexPath {
            
            let sourcePath = events.indexPath(forEvent: draggedEvent!)!
            events.moveItem(at: sourcePath, to: proposedDropIndexPath)
            
            collectionView.animator().moveItem(at: currentIndexPath, to: proposedDropIndexPath)
        }
        
        return .move
        
    }

    func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItemsAt indexPaths: Set<IndexPath>) {
        
        if let indexPath = indexPaths.first,
            let item = collectionView.item(at: indexPath) {
            
            draggedIndexPath = indexPath
            draggedItem = item
            draggedEvent = events.at(indexPath: indexPath)
        }
    }
    
    
    func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, dragOperation operation: NSDragOperation) {
        
        draggedItem = nil
        draggedIndexPath = nil
        draggedEvent = nil
    }
    
    func collectionView(_ collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, indexPath: IndexPath, dropOperation: NSCollectionViewDropOperation) -> Bool {

        onReorder?()
        
        return true
    }
    
    // MARK: - Editing
    // -----------------------------------------------------------------------
    
    func handleEdit(item: CalendarCollectionItem) {
        if let task = item.event.value?.task {
            edit(task: task)
        } else if let entry = item.event.value?.timerEntry {
            edit(timerEntry: entry)
        }
    }
    
    func edit(task: Task) {
        // Find the item
        guard let item = collectionItem(forTask: task) else { return }
        
        let view = item.view
        
        if editTaskController == nil {
            editTaskController = EditTaskViewController()
            
            editTaskController?.onFinishEditing = {
                self.editTaskPopover?.close()
                self.reloadData()
            }
        }
        
        if editTaskPopover == nil {
            editTaskPopover = NSPopover()
            editTaskPopover?.contentViewController = editTaskController
            editTaskPopover?.behavior = .transient
            editTaskPopover?.animates = false
        }
        
        editTaskController?.task.value = task
        
        editTaskPopover?.show(relativeTo: view.bounds, of: view, preferredEdge: .minY)
    }
    
    func edit(timerEntry: TimerEntry) {
        guard let item = collectionItem(forEntry: timerEntry) else { return }
        
        let view = item.view
        
        if editTimerEntryController == nil {
            editTimerEntryController = EditTimerEntryController()
            
            editTimerEntryController?.onFinishEditing = {
                self.editTimerEntryPopover?.close()
                self.reloadData()
            }
        }
        
        if editTimerEntryPopover == nil {
            editTimerEntryPopover = NSPopover()
            editTimerEntryPopover?.contentViewController = editTimerEntryController
            editTimerEntryPopover?.behavior = .transient
            editTimerEntryPopover?.animates = false
            editTimerEntryPopover?.delegate = self
        }
        
        editTimerEntryController?.entry.value = timerEntry
        
        editTimerEntryPopover?.show(relativeTo: view.bounds, of: view, preferredEdge: .minY)
    }
    
//    func popoverWillClose(_ notification: Notification) {
//        reloadData()
//    }
    
    func collectionItem(forTask task: Task) -> CalendarCollectionItem? {
        for item in collectionView.visibleItems() {
            if let item = item as? CalendarCollectionItem,
                let itemTask = item.event.value?.task,
                itemTask == task {
                
                return item
            }
        }
        
        return nil
    }
    
    func collectionItem(forEntry entry: TimerEntry) -> CalendarCollectionItem? {
        for item in collectionView.visibleItems() {
            if let item = item as? CalendarCollectionItem,
                let itemEntry = item.event.value?.timerEntry,
                itemEntry == entry {
                
                return item
            }
        }
        
        return nil
    }
    
    // MARK: - Actions
    // -----------------------------------------------------------------------
    
    @IBAction func createAction(_ sender: Any) {
        onCreate?(nil)
    }
    
    func removeSelectedTasks() {
        let context = AppDelegate.viewContext
        
        for task in selectedTasks {
            task.remove(in: context)
        }
    }
    
    func moveToNextWeek() {
        moveBy(weeks: 1)
    }
    
    func moveToPreviousWeek() {
        moveBy(weeks: -1)
    }
    
    func moveBy(weeks: Int) {
        for task in selectedTasks {
            guard let date = (task.plannedFor as Date?) else { continue }
            let newDate = (date + weeks.week).startOf(component: .weekOfYear)
            task.plannedFor = newDate as NSDate
        }
    }
    
    func removeSelectedEntries() {
        let context = AppDelegate.viewContext
        
        for entry in selectedEntries {
            context.delete(entry)
        }
    }
    
    // MARK: - Handling selection
    // -----------------------------------------------------------------------
    
    func setupSelectionObserving() {
        collectionView.addObserver(self, forKeyPath: "selectionIndexPaths", options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "selectionIndexPaths" {
            if let value = change?[.newKey] as? Set<IndexPath> {
                updateReactiveSelection(fromIndexPaths: value)
            }
            
        }
    }
    
    func updateReactiveSelection(fromIndexPaths indexPaths: Set<IndexPath>) {
        var events = Set<CalendarEvent>()
        
        for path in indexPaths {
            if let item = collectionView.item(at: path) as? CalendarCollectionItem,
                let event = item.event.value {
                
                events.insert(event)
            }
        }
        
        selectedEvents.value = events
    }
    
    
    
    // MARK: - Updating menu
    // -----------------------------------------------------------------------
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()
        
        if let task = selectedTasks.first, selectedTasks.count == 1, selectedEntries.count == 0 {
            menu.addItem(NSMenuItem(title: "Move to next week", action: #selector(moveToNextWeek), keyEquivalent: ""))
            menu.addItem(NSMenuItem(title: "Move to previous week", action: #selector(moveToPreviousWeek), keyEquivalent: ""))
            
            menu.addItem(NSMenuItem.separator())
            
            menu.addItem(withTitle: "Remove '\(task.title ?? "")'", action: #selector(removeSelectedTasks), keyEquivalent: "")
            
        }
        
        if selectedEntries.count == 1, selectedTasks.count == 0 {
            menu.addItem(withTitle: "Remove entry", action: #selector(removeSelectedEntries), keyEquivalent: "")
        }
    }
    

    // MARK: - Creating time entries
    // -----------------------------------------------------------------------
    
    func handleDoubleClick(event: NSEvent) {
        let location = collectionView.convert(event.locationInWindow, from: nil)
        guard let section = collectionLayout.sectionIndexPath(atPoint: location) else { return }
        
        let time = collectionLayout.time(pointValue: location.y)
        let date = (config.firstDay + section.section.days).startOf(component: .day).addingTimeInterval(time)
        
        switch config.style {
        case .hybrid, .entries:
            createEntry(startTime: date)
        case .plan:
            createTask(plannedFor: date)
        }
    }
    
    func createEntry(startTime: Date) {
        let context = AppDelegate.viewContext
        let entry = TimerEntry(entity: TimerEntry.entity(), insertInto: context)
        
        entry.lane = LaneId.general.rawValue
        entry.startedAt = startTime as NSDate
        entry.endedAt = (startTime + 15.minutes) as NSDate
    }
    
    func createTask(plannedFor date: Date) {
        onCreate?(date)
    }
}
