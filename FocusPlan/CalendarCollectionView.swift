//
//  CalendarCollectionView.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/8/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Cocoa

class CalendarCollectionView: NSCollectionView {
    
    override func rightMouseDown(with event: NSEvent) {
        guard let menu = self.menu else {
            Swift.print("No menu!")
            return super.rightMouseDown(with: event)
        }
        
        let point = convert(event.locationInWindow, from: nil)
        
        guard let indexPath = indexPathForItem(at: point) else {
            return
        }
        
        Swift.print("Going to select at index path: \(indexPath)")

        
        if !selectionIndexPaths.contains(indexPath) {
            self.selectionIndexPaths = Set<IndexPath>([indexPath])
            
//            self.selectItems(at: Set<IndexPath>([indexPath]), scrollPosition: .centeredVertically)
        }
        

        NSMenu.popUpContextMenu(menu, with: event, for: self)
    }

    override func menu(for event: NSEvent) -> NSMenu? {
        return nil
    }
    
}
