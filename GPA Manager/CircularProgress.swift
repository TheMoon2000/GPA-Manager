//
//  CircularProgress.swift
//  GPA Manager
//
//  Created by Jia Rui Shan on 5/23/17.
//  Copyright © 2017 Jerry Shan. All rights reserved.
//

import Cocoa

class CircularProgress: NSView {
    
    var backgroundColor = NSColor(white: 0.85, alpha: 0.9)
    var progressColor = NSColor(red: 0.3, green: 0.6, blue: 0.8, alpha: 0.99)
    
    dynamic var percentage: CGFloat = 0 {
        didSet {
            self.needsDisplay = true
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        let diameter = self.frame.width
        self.wantsLayer = true
        self.layer?.cornerRadius = diameter / 2
        let center = NSMakePoint(NSMidX(self.bounds), NSMidY(self.bounds))
        
        let b2 = NSBezierPath()
        b2.appendArc(withCenter: center, radius: self.frame.width / 2 - 1.5, startAngle: 90, endAngle: -270, clockwise: true)
        b2.lineWidth = 3
        backgroundColor.set()
        b2.stroke()
        
        let bezier = NSBezierPath()
        bezier.appendArc(withCenter: center, radius: self.frame.width / 2 - 1.5, startAngle: 90, endAngle: 90 - 360 * percentage, clockwise: true)
        bezier.lineWidth = 3
        bezier.lineCapStyle = .roundLineCapStyle
        progressColor.set()
        bezier.stroke()
        
    }
    
    override static func defaultAnimation(forKey key: String) -> Any? {
        if key == "percentage" {
            return CABasicAnimation()
        }
        return super.defaultAnimation(forKey: key)
    }
    
}
