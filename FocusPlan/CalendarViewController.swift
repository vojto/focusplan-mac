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
        
        // Do view setup here.
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
        }
        
        fatalError("unknown kind: \(kind)")
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
}
