//
//  HorizontalSlider.swift
//  GPA Manager
//
//  Created by Jia Rui Shan on 28/05/2017.
//  Copyright © 2017 Jerry Shan. All rights reserved.
//

import Cocoa

class HorizontalSlider: NSView {
    
    var max: CGFloat = 1 {
        didSet {
            self.needsDisplay = true
        }
    }
    var score: CGFloat = 1 {
        didSet {
            self.needsDisplay = true
        }
    }
    
    func lineColor() -> NSColor {
        if score / max < 0.3 {
            return NSColor(red: 178/255, green: 59/255, blue: 54/255, alpha: 1)
        } else if score / max < 0.4 {
            return NSColor(red: 212/255, green: 83/255, blue: 80/255, alpha: 1)
        } else if score / max < 0.5 {
            return NSColor(red: 243/255, green: 175/255, blue: 107/255, alpha: 1)
        } else if score / max < 0.6 {
            return NSColor(red: 245/255, green: 224/255, blue: 97/255, alpha: 1)
        } else if score / max < 0.7 {
            return NSColor(red: 212/255, green: 238/255, blue: 53/255, alpha: 1)
        } else if score / max < 0.8 {
            return NSColor(red: 131/255, green: 230/255, blue: 77/255, alpha: 1)
        } else if score / max < 0.85 {
            return NSColor(red: 104/255, green: 229/255, blue: 101/255, alpha: 1)
        } else if score / max < 0.9 {
            return NSColor(red: 128/255, green: 234/255, blue: 182/255, alpha: 1)
        } else if score / max < 0.95 {
            return NSColor(red: 119/255, green: 214/255, blue: 239/255, alpha: 1)
        } else {
            return NSColor(red: 130/255, green: 188/255, blue: 250/255, alpha: 1)
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let thickness = self.frame.height / 2
        
        let bezierPath = NSBezierPath()
        bezierPath.lineWidth = thickness
        
        bezierPath.lineCapStyle = .roundLineCapStyle
        
        let startPoint = NSPoint(x: thickness/2, y: thickness)
        var endPoint = NSPoint(x: (self.frame.width - thickness) * score / max + thickness/2, y: thickness)
        
        if max < score {
            endPoint = NSPoint(x: self.frame.width - thickness/2, y: thickness)
        }
        
        bezierPath.appendPoints(NSPointArray(mutating: [startPoint, endPoint]), count: 2)
        
        lineColor().set()
        bezierPath.stroke()
                
    }
    
    override func awakeFromNib() {
//        self.addTrackingArea(NSTrackingArea(rect: self.bounds, options: NSTrackingAreaOptions(rawValue: 129), owner: self, userInfo: nil))
    }
    
}
