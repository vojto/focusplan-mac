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

let kHourHeaderIdentifier = "CalendarHourHeader"

let kHourHeader = "HourHeader"
let kTimeLine = "TimeLine"
let kSectionLine = "SectionLine"
let kSectionLabel = "SectionLabel"

class CalendarCollectionLayout: NSCollectionViewLayout {
    
    /* TODO: Pick lowest of these for day start:
     
     - First recorded event
     - Current time
     - 8am / read day start from settings
     */
    
    var config: PlanConfig {
        return controller.config
    }
    
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
        let now = (Date() - 10.minutes).startOf(component: .hour)
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
    
    let hourHeight = Double(75)
    
    override var collectionViewContentSize: NSSize {
        guard let collectionView = self.collectionView else { return NSZeroSize }
        
        let width = collectionView.bounds.size.width
        
        let hours = (dayEnd - dayStart) / (60 * 60)
        
        let height = CGFloat(hours * hourHeight)
        
        return NSSize(width: width, height: height)
    }
    
    func duration(pointValue: CGFloat) -> TimeInterval {
        let secondHeight = hourHeight / 3600
        
        return Double(pointValue) / secondHeight
    }
    
    func time(pointValue: CGFloat) -> TimeInterval {
        return duration(pointValue: pointValue - topMargin) + dayStart
    }
    
    let leftMargin: CGFloat = 50.0
    let topMargin: CGFloat = 20.0
    
    var innerFrame: NSRect {
        let size = collectionViewContentSize
        var frame = NSRect(x: 0, y: 0, width: size.width, height: size.height)
        
        frame.size.width -= leftMargin
        frame.origin.x += leftMargin
        
        frame.size.height -= topMargin
        frame.origin.y += topMargin
        
        return frame
    }
    
    
    // MARK: - Getting all layout attributes
    // ------------------------------------------------------------------------
    
    override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
        let paths = controller.allIndexPaths()
        
        // Assign starting date to first task event in case we want exact numbers
        
        if config.style != .plan {
            var markedFirstEvent = false
            
            for path in paths {
                let event = controller.event(atIndexPath: path)!
                
                if event.type == .task {
                    event.startsAt = nil
                    
                    if !markedFirstEvent {
                        event.startsAt = Date().timeIntervalSinceStartOfDay
                        markedFirstEvent = true
                    }
                }
            }
        }
        
        
        var attributes = [NSCollectionViewLayoutAttributes]()
        
        // Events
        for path in paths {
            if let attribute = layoutAttributesForItem(at: path) {
                attributes.append(attribute)
            }
        }
        

        if config.style != .plan {
            // Hour labels
            let countLabels = Int(dayDuration / labelEvery)
            for i in 0...countLabels {
                let path = IndexPath(item: i, section: 0)
                if let attribute = layoutAttributesForSupplementaryView(ofKind: kHourHeader, at: path) {
                    attributes.append(attribute)
                }
            }
            
            // Current hour label
            if let timeLine = layoutAttributesForDecorationView(ofKind: kTimeLine, at: IndexPath(item: 0, section: CalendarDecorationSection.hourLine.rawValue)) {
                attributes.append(timeLine)
            }
        }
        
        
        if config.detail == .weekly {
            // Section lines & labels
            for i in 0...config.range.dayCount {
                if let attribute = layoutAttributesForDecorationView(ofKind: kSectionLine, at: IndexPath(item: i, section: CalendarDecorationSection.sectionLine.rawValue)) {
                    attributes.append(attribute)
                }
                
                if config.range.dayCount > 1 {
                    if let attribute = layoutAttributesForDecorationView(ofKind: kSectionLabel, at: IndexPath(item: i, section: CalendarDecorationSection.sectionLabel.rawValue)) {
                        attributes.append(attribute)
                    }
                }
            }
        }
        
        
        return attributes
    }
    
    // MARK: - Getting specific layout attributes
    // ------------------------------------------------------------------------
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {

        let attributes = NSCollectionViewLayoutAttributes(forItemWith: indexPath)
        
        guard let frame = frameFor(eventAt: indexPath) else {
            return nil
        }

        attributes.frame = frame
        
        return attributes
    }
    
    func frameFor(eventAt indexPath: IndexPath) -> NSRect? {
        guard let event = controller.event(atIndexPath: indexPath) else { return nil }
        guard let lane = event.lane else { return nil }
        
        if event.isHidden {
            return nil
        }
        
        let sections = controller.config.range.dayCount
        let sectionWidth = innerFrame.size.width / CGFloat(sections)
        
        var x = CGFloat(indexPath.section) * sectionWidth + innerFrame.origin.x
        
        let startingInterval: TimeInterval
        let durationInterval: TimeInterval
        
        
        startingInterval = startTime(forEventAt: indexPath) - dayStart
        durationInterval = event.duration

        let relativeStart = startingInterval / dayDuration
        
        let y = innerFrame.origin.y + CGFloat(relativeStart) * innerFrame.size.height
        
        let height = CGFloat(durationInterval / dayDuration) * innerFrame.size.height
        
        // Offset x by lane number
        let laneWidth = sectionWidth / CGFloat(config.lanes.count)
        guard let laneNumber = config.lanes.index(of: lane) else { return nil }
        let laneOffset = CGFloat(laneNumber) * laneWidth
        
        x += laneOffset
        
        var frame: NSRect
        
        frame = NSRect(x: x, y: y, width: laneWidth, height: height).insetBy(dx: 1.0, dy: 0)
        
//        if config.durationsOnly {
//            frame = frame.insetBy(dx: 2.0, dy: 0.0)
//        }
        
        if frame.size.height < 0 {
            return nil
        }
        
        return frame
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
        
        let contentSize = collectionViewContentSize
        
        if elementKind == kHourHeader {
            let attributes = NSCollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
            
            let yTime = labelEvery * Double(indexPath.item)
            let y = innerFrame.origin.y + CGFloat(yTime / dayDuration) * contentSize.height
            
            attributes.frame = NSRect(x: 0, y: y, width: 50, height: 40)
            
            return attributes
        }
        
        return nil
    }
    
    
    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
        if elementKind == kTimeLine {
            let attributes = NSCollectionViewLayoutAttributes(forDecorationViewOfKind: kTimeLine, with: indexPath)
            
            let now = Date().timeIntervalSince(Date().startOf(component: .day)) - dayStart
            let y = innerFrame.origin.y + CGFloat(now / dayDuration) * innerFrame.size.height
            
            attributes.frame = NSRect(x: innerFrame.origin.x - 10, y: y - 3, width: innerFrame.size.width + 10, height: 7)
            attributes.zIndex = -1
            
            return attributes
            
        } else if elementKind == kSectionLine {
            let attributes = NSCollectionViewLayoutAttributes(forDecorationViewOfKind: kSectionLine, with: indexPath)
            
            attributes.isHidden = (indexPath.item == 0)
            attributes.zIndex = -1
            attributes.frame = sectionFrame(at: indexPath.item)
            
            return attributes
        } else if elementKind == kSectionLabel {
            let attributes = NSCollectionViewLayoutAttributes(forDecorationViewOfKind: kSectionLabel, with: indexPath)
            
            var frame = sectionFrame(at: indexPath.item)
            frame.size.height = 20
            
            attributes.frame = frame
            
            return attributes
        }
        
        return nil
    }
    
    func sectionFrame(at index: Int) -> NSRect {
        let sections = controller.config.range.dayCount
        let sectionWidth = innerFrame.size.width / CGFloat(sections)
        
        let marginLeft = innerFrame.origin.x
        let x = marginLeft + sectionWidth * CGFloat(index)
        
        return NSRect(x: x, y: 0, width: sectionWidth, height: innerFrame.size.height)
    }
    
    // MARK: - Timestamps for events
    // ------------------------------------------------------------------------
    
    func endTime(forEventAt indexPath: IndexPath) -> TimeInterval {
        let event = controller.event(atIndexPath: indexPath)!
        
        return startTime(forEventAt: indexPath) + event.duration
    }
    
    func startTime(forEventAt indexPath: IndexPath) -> TimeInterval {
        let event = controller.event(atIndexPath: indexPath)!
        
        if let start = event.startsAt {
            return start
        } else if indexPath.item == 0 {
            return dayStart
        } else {
            let previousPath = IndexPath(item: indexPath.item - 1, section: indexPath.section)
            let time = endTime(forEventAt: previousPath)
            return time
        }
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
    
    // MARK: - Dropping items
    // ------------------------------------------------------------------------
    
    override func layoutAttributesForDropTarget(at pointInCollectionView: NSPoint) -> NSCollectionViewLayoutAttributes? {
        
        // Find the item on top of which we are
        
        for path in controller.events.allIndexPaths {
            if let frame = frameFor(eventAt: path),
                frame.contains(pointInCollectionView) {
                
                let attributes = NSCollectionViewLayoutAttributes(forItemWith: path)
                return attributes
            }
        }
        
        if let indexPath = sectionIndexPath(atPoint: pointInCollectionView) {
            return NSCollectionViewLayoutAttributes(forInterItemGapBefore: indexPath)
        }
        
        return nil
    }
    
    func sectionIndexPath(atPoint point: NSPoint) -> IndexPath? {
        let sections = controller.events.sections
        
        for i in 0...sections.lastIndex {
            let frame = sectionFrame(at: i)
            let countEvents = sections[i].count
            let lastIndex = countEvents > 0 ? countEvents - 1 : 0
            
            if frame.contains(point) {
                return IndexPath(item: lastIndex, section: i)
            }
        }
        
        return nil
    }
    
    // MARK: - Invalidation
    // ------------------------------------------------------------------------
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: NSRect) -> Bool {
        return true
    }
}
