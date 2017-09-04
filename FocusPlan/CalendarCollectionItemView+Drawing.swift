//
//  CalendarCollectionItemView+Drawing.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 9/4/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import AppKit

extension CalendarCollectionItemView {
    func drawBackground() {
        let cornerRadius: CGFloat = 4.0
        let bounds = self.bounds.insetBy(dx: 0.5, dy: 0.5)

        let path = NSBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)

        background.setFill()
        path.fill()


        let darkerBackground = background.addHue(0, saturation: 0, brightness: -0.2, alpha: 0)
        var darkerBounds = bounds
        let newHeight = bounds.size.height * CGFloat(backgroundProgress)
        darkerBounds.origin.y += darkerBounds.size.height - newHeight
        darkerBounds.size.height = newHeight
        let darkerPath = NSBezierPath(roundedRect: darkerBounds, cornerRadius: cornerRadius)
        darkerBackground.setFill()
        darkerPath.fill()

        let gradient = NSGradient(colors: [NSColor.white.alpha(0.15), NSColor.white.alpha(0), NSColor.white.alpha(0)])
        let gradientHeight: CGFloat = 200.0
        let gradientRect = NSRect(x: 0, y: bounds.size.height - gradientHeight, width: bounds.size.width, height: gradientHeight)
        gradient?.draw(in: gradientRect, angle: -85)
    }

    func drawHandle() {
        for i in 0...1 {
            let handleColor = NSColor.black.alpha(0.35)
            let handleWidth: CGFloat = 32.0
            let handleHeight: CGFloat = 1.0
            let handleSpace: CGFloat = 1.0
            let handleFrame = NSRect(
                x: (bounds.size.width - handleWidth)/2,
                y: 3 + CGFloat(i) * (handleHeight + handleSpace),
                width: handleWidth,
                height: handleHeight
            )

            handleColor.setFill()
            NSRectFillUsingOperation(handleFrame, .sourceOver)
        }
    }
}
