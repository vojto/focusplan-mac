//
//  CalendarViewController.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 4/28/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Cocoa
import SwiftDate

class CalendarViewController: NSViewController, NSCollectionViewDataSource, NSCollectionViewDelegate {

    @IBOutlet var collectionView: NSCollectionView!
    let collectionLayout = CalendarCollectionLayout()
    
    var events = [CalendarEvent]()
    var firstDay = Date().startOf(component: .day)
    var sectionsCount = 1
    
    // MARK: - Lifecycle
    // ------------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.collectionViewLayout = collectionLayout
        
        let nib = NSNib(nibNamed: "CalendarHourHeader", bundle: nil)
        collectionView.register(nib, forSupplementaryViewOfKind: kHourHeader, withIdentifier: kHourHeaderIdentifier)
        
        collectionLayout.register(CalendarTimeLine.self, forDecorationViewOfKind: kTimeLine)
        
        // Do view setup here.
    }
    
    func reloadData() {
        Swift.print("Reloading data for the  calendar view!")
        

        self.collectionView.reloadData()
        
        
    }
    
    // MARK: - Feeding data to the collection view
    // ------------------------------------------------------------------------
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
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
            
            let interval = event.startsAt.timeIntervalSince(firstDay)
            
            let dayIndex = Int(floor(interval / (60 * 60 * 24)))
            
            let path = IndexPath(item: i, section: dayIndex)
            paths.append(path)
        }
        
        return paths
    }
    
    func event(atIndexPath path: IndexPath) -> CalendarEvent? {
        return events.at(path.item)
    }
}
