//
//  CalendarCollectionView.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/8/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Cocoa
import ReactiveSwift
import enum Result.NoError

class CalendarCollectionView: NSCollectionView {
    
    var scrollSignal: Signal<(), NoError>!
    var scrollObserver: Observer<(), NoError>!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    func setup() {
        let (signal, observer) = Signal<(), NoError>.pipe()
        scrollSignal = signal
        scrollObserver = observer
    }
    
    override func rightMouseDown(with event: NSEvent) {
        guard let menu = self.menu else {
            Swift.print("No menu!")
            return super.rightMouseDown(with: event)
        }
        
        let point = convert(event.locationInWindow, from: nil)
        
        guard let indexPath = indexPathForItem(at: point) else {
            return
        }

        
        if !selectionIndexPaths.contains(indexPath) {
            self.selectionIndexPaths = Set<IndexPath>([indexPath])
            
//            self.selectItems(at: Set<IndexPath>([indexPath]), scrollPosition: .centeredVertically)
        }
        

        NSMenu.popUpContextMenu(menu, with: event, for: self)
    }

    override func menu(for event: NSEvent) -> NSMenu? {
        return nil
    }
    
    
    
    override func scrollWheel(with event: NSEvent) {
        super.scrollWheel(with: event)
        
        scrollObserver.send(value: ())
    }
    
}
