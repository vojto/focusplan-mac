//
//  CalendarCollectionLayout.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 4/28/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit
import SwiftDate

// https://www.objc.io/issues/3-views/collection-view-layouts/

let kHourHeader = "HourHeader"
let kHourHeaderIdentifier = "CalendarHourHeader"
let kTimeLine = "TimeLine"

class CalendarCollectionLayout: NSCollectionViewLayout {
    
    /* TODO: Pick lowest of these for day start:
     
     - First recorded event
     - Current time
     - 8am / read day start from settings
     */
    
    let lanesCount = 2
    
    var dayStart: TimeInterval = 8 * 60 * 60
    let dayEnd: TimeInterval = 20 * 60 * 60
    var dayDuration: TimeInterval { return dayEnd - dayStart }
    
    let labelEvery: TimeInterval = 1 * 60 * 60
    
    var controller: CalendarViewController {
        return collectionView!.dataSource as! CalendarViewController
    }
    
    // MARK: - Lifecycle
    // ------------------------------------------------------------------------
    
    override init() {
        let now = Date() - 10.minutes
        let dayStart = now.startOf(component: .day)
        
        let timeNow = now.timeIntervalSince(dayStart)
        let defaultStart: TimeInterval = 8 * 60 * 60
        
        self.dayStart = min(timeNow, defaultStart)
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Getting content frame
    // ------------------------------------------------------------------------
    
    override var collectionViewContentSize: NSSize {
        guard let collectionView = self.collectionView else { return NSZeroSize }
        
        let width = collectionView.bounds.size.width
        
        let hourHeight = Double(75)
        let hours = (dayEnd - dayStart) / (60 * 60)
        
        let height = CGFloat(hours * hourHeight)
        
        return NSSize(width: width, height: height)
    }
    
    var innerFrame: NSRect {
        let leftMargin: CGFloat = 50.0
        let size = collectionViewContentSize
        var frame = NSRect(x: 0, y: 0, width: size.width, height: size.height)
        
        frame.size.width -= leftMargin
        frame.origin.x += leftMargin
        
        return frame
    }
    
    
    // MARK: - Getting all layout attributes
    // ------------------------------------------------------------------------
    
    override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
        let paths = controller.allIndexPaths()
        
        var attributes = [NSCollectionViewLayoutAttributes]()
        
        // Events
        for path in paths {
            if let attribute = layoutAttributesForItem(at: path) {
                attributes.append(attribute)
            }
        }
        
        // Hour labels
        let countLabels = Int(dayDuration / labelEvery)
        for i in 0...countLabels {
            let path = IndexPath(item: i, section: 0)
            if let attribute = layoutAttributesForSupplementaryView(ofKind: kHourHeader, at: path) {
                attributes.append(attribute)
            }
        }
        
        // Current hour label
        if let timeLine = layoutAttributesForDecorationView(ofKind: kTimeLine, at: IndexPath(item: 0, section: 0)) {
            attributes.append(timeLine)
        }
        
        return attributes
    }
    
    // MARK: - Getting specific layout attributes
    // ------------------------------------------------------------------------
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
        
        guard let event = controller.event(atIndexPath: indexPath) else { return nil }
        guard let laneNumber = event.lane else { return nil }
        
        let attributes = NSCollectionViewLayoutAttributes(forItemWith: indexPath)

        let sections = controller.sectionsCount
        let sectionWidth = innerFrame.size.width / CGFloat(sections)
        
        var x = CGFloat(indexPath.section) * sectionWidth + innerFrame.origin.x
        
        let relativeStart = (event.startsAt.dayTimeInterval - dayStart) / dayDuration
        
        let y = CGFloat(relativeStart) * innerFrame.size.height
        
        let height = CGFloat(event.duration / dayDuration) * innerFrame.size.height
        
        // Offset x by lane number
        let laneWidth = sectionWidth / CGFloat(lanesCount)
        let laneOffset = CGFloat(laneNumber) * laneWidth
        
        x += laneOffset
        
        attributes.frame = NSRect(x: x, y: y, width: laneWidth, height: height).insetBy(dx: 1.0, dy: 0)
        
        return attributes
    }
    
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
        
        let contentSize = collectionViewContentSize
        
        if elementKind == kHourHeader {
            let attributes = NSCollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
            
            let yTime = labelEvery * Double(indexPath.item)
            let y = CGFloat(yTime / dayDuration) * contentSize.height
            
            attributes.frame = NSRect(x: 0, y: y, width: 50, height: 40)
            
            return attributes
        }
        
        return nil
    }
    
    
    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
        if elementKind == kTimeLine {
            let attributes = NSCollectionViewLayoutAttributes(forDecorationViewOfKind: kTimeLine, with: indexPath)
            
            let now = Date().timeIntervalSince(Date().startOf(component: .day)) - dayStart
            let y = CGFloat(now / dayDuration) * innerFrame.size.height
            
            attributes.frame = NSRect(x: innerFrame.origin.x - 10, y: y - 3, width: innerFrame.size.width + 10, height: 7)
            attributes.zIndex = -1
            
            return attributes
        }
        
        return nil
    }
    
    // MARK: - Getting labels
    // ------------------------------------------------------------------------
    
    public func hourHeaderLabel(at indexPath: IndexPath) -> String {
        let time = dayStart + Double(indexPath.item) * labelEvery
        
        let date = Date().startOf(component: .day).addingTimeInterval(time)
        
        return date.string(custom: "h a")
    }
    
    /*
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
        return nil // TODO ...
    }
    */
}
