//
//  String+Extensions.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 4/26/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit

extension String {
    func match(regex str: String) -> [String]? {
        let regex = try! NSRegularExpression(pattern: str, options: .caseInsensitive)
        if let match = regex.firstMatch(in: self, options: [], range: NSMakeRange(0, self.length)) {
            
            var matches = [String]()

            for i in 0...(match.numberOfRanges - 1) {
                let range = match.rangeAt(i)
                let str = self.substr(start: range.location, end: range.location + range.length)
                matches.append(str)
            }
            
            return matches
        } else {
            return nil
        }
    }
}
