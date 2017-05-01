//
//  CalendarCollectionLayout.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 4/28/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit

// https://www.objc.io/issues/3-views/collection-view-layouts/

class CalendarCollectionLayout: NSCollectionViewLayout {
    override var collectionViewContentSize: NSSize {
        /*
 // Don't scroll horizontally
 CGFloat contentWidth = self.collectionView.bounds.size.width;
 
 // Scroll vertically to display a full day
 CGFloat contentHeight = DayHeaderHeight + (HeightPerHour * HoursPerDay);
 
 CGSize contentSize = CGSizeMake(contentWidth, contentHeight);
 return contentSize;
    */
        
        guard let collectionView = self.collectionView else { return NSZeroSize }
        
        let width = collectionView.bounds.size.width
        
        let hourHeight = 100
        let hours = 16
        
        let height = CGFloat(hours * hourHeight)
        
        
        
        return NSSize(width: width, height: height)
    }
    
    
    
    override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
        return [] // TODO...
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
        return nil // TODO ...
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
        return nil // TODO ...
    }
}
