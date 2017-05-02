//
//  NSButton+Additions.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/1/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit
import ReactiveSwift
import ReactiveCocoa

//extension Reactive where Base: NSButton {
//    public var isHidden: BindingTarget<Bool> {
//        return makeBindingTarget { $0.isHidden = $1 }
//    }
//}

extension Reactive where Base: NSView {
    public var isHidden: BindingTarget<Bool> {
        return makeBindingTarget { $0.isHidden = $1 }
    }
}
