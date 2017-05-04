//
//  CalendarViewController.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 4/28/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Cocoa
import SwiftDate

enum CalendarDecorationSection: Int {
    case hourLine = 0
    case sectionLine = 1
    case sectionLabel = 2
}

fileprivate let kCalendarDraggedType = "CalendarDraggedType"

class CalendarViewController: NSViewController, NSCollectionViewDataSource, NSCollectionViewDelegate {

    @IBOutlet var collectionView: NSCollectionView!
    let collectionLayout = CalendarCollectionLayout()
    
    var events = [CalendarEvent]() {
        didSet {
            var offset: TimeInterval = 0
            
            for event in events {
                event.durationOffset = offset
                offset += event.duration
            }
        }
    }
    
    var config = PlanConfig.defaultConfig {
        didSet {
            reloadData()
        }
    }
    
    // MARK: - Lifecycle
    // ------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.collectionViewLayout = collectionLayout
        
        let nib = NSNib(nibNamed: "CalendarHourHeader", bundle: nil)
        collectionView.register(nib, forSupplementaryViewOfKind: kHourHeader, withIdentifier: kHourHeaderIdentifier)
        
        collectionLayout.register(CalendarTimeLine.self, forDecorationViewOfKind: kTimeLine)
        
        collectionLayout.register(CalendarSectionLine.self, forDecorationViewOfKind: kSectionLine)
        
        collectionLayout.register(CalendarSectionLabel.self, forDecorationViewOfKind: kSectionLabel)
        
        collectionView.isSelectable = true
        collectionView.allowsEmptySelection = true
        collectionView.allowsMultipleSelection = true
        
        collectionView.register(forDraggedTypes: [kCalendarDraggedType])

    }
    
    func reloadData() {
        NSAnimationContext.current().duration = 0
        self.collectionView.reloadData()
    }
    
    // MARK: - Feeding data to the collection view
    // ------------------------------------------------------------------------
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return config.range.dayCount
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }
    
    // MARK: - Making views
    // ------------------------------------------------------------------------
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: "CalendarCollectionItem", for: indexPath) as! CalendarCollectionItem
        
        item.event.value = events[indexPath.item]
        
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> NSView {
        
        if kind == kHourHeader {
            let view = collectionView.makeSupplementaryView(ofKind: kind, withIdentifier: kHourHeaderIdentifier, for: indexPath) as! CalendarHourHeader
            
            view.textField.stringValue = collectionLayout.hourHeaderLabel(at: indexPath)
            
            return view
        } else if kind == kTimeLine {
            Swift.print("🌈 Making the time line!")
            
            return NSView()
        } else {
            return collectionView.makeSupplementaryView(ofKind: kind, withIdentifier: "", for: indexPath)
        }
    }
    
    
    // MARK: - Accessing events
    // ------------------------------------------------------------------------

    func allIndexPaths() -> [IndexPath] {
        var paths = [IndexPath]()
        
        for (i, event) in events.enumerated() {
            // For now, stick them all in one section
            
            let rangeStart = config.range.start.startOf(component: .day)
            
            let interval = event.startsAt.timeIntervalSince(rangeStart)
            
            let dayIndex = Int(floor(interval / (60 * 60 * 24)))
            
            if dayIndex < 0 {
                continue
            }
            
            let path = IndexPath(item: i, section: dayIndex)
            paths.append(path)
        }
        
        return paths
    }
    
    func event(atIndexPath path: IndexPath) -> CalendarEvent? {
        return events.at(path.item)
    }
    
    // MARK: - Drag and drop
    // ------------------------------------------------------------------------
    
    
    
    func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt indexPath: IndexPath) -> NSPasteboardWriting? {
        
        Swift.print("Getting pasteboard writer for item at index path: \(indexPath)")
        
        return "some item" as NSString
        
        /*
        if let url = URL(dataRepresentation: data, relativeTo: nil) {
            Swift.print("Writing URL: \(url)")
            
            return url as NSURL
        } else {
            return nil
        }
        */
    }
 
    
//    func collectionView(_ collectionView: NSCollectionView, writeItemsAt indexPaths: Set<IndexPath>, to pasteboard: NSPasteboard) -> Bool {
//        return true
//    }
    
    func collectionView(_ collectionView: NSCollectionView, canDragItemsAt indexes: IndexSet, with event: NSEvent) -> Bool {
        
        Swift.print("Checking if we can drag items at \(indexes)")
        
        return true
    }
    
    func collectionView(_ collectionView: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo, proposedIndex proposedDropIndex: UnsafeMutablePointer<Int>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionViewDropOperation>) -> NSDragOperation {
        
        Swift.print("Validating drop")
        
        return .move
    }
    
//    func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItemsAt indexes: IndexSet) {
//        Swift.print("Dragging session will begin!")
//    }
//    
//    func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, dragOperation operation: NSDragOperation) {
//        
//    }
    
    func collectionView(_ collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, index: Int, dropOperation: NSCollectionViewDropOperation) -> Bool {
        
        Swift.print("Accepting drop")
        
        return true
    }
    
}
