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

class CalendarViewController: NSViewController, NSCollectionViewDataSource, NSCollectionViewDelegate {

    @IBOutlet var collectionView: NSCollectionView!
    let collectionLayout = CalendarCollectionLayout()
    
    var events = CalendarEventsCollection()
    
    var onReorder: (() -> ())?
    
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
        
        collectionView.register(forDraggedTypes: [NSStringPboardType])


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
        return events.sections.at(section)?.count ?? 0
    }
    
    // MARK: - Making views
    // ------------------------------------------------------------------------
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: "CalendarCollectionItem", for: indexPath) as! CalendarCollectionItem
        
        item.event.value = events.at(indexPath: indexPath)
        
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
    
    
}


