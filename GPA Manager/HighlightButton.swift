//
//  HighlightButton.swift
//  GPA Manager
//
//  Created by Jia Rui Shan on 27/05/2017.
//  Copyright © 2017 Jerry Shan. All rights reserved.
//

import Cocoa

class HighlightButton: NSButton {
    
//    let bright = CIFilter(name: "CIColorControls", withInputParameters: [
//        "inputSaturation": 1.0,
//        "inputBrightness": 0.0,
//        "inputContrast": 1.0])
    
    
    var radius: CGFloat = 3
    
    var titleString = "" {
        didSet {
            self.needsDisplay = true
        }
    }

    var label = NSTextField()
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let bezierPath = NSBezierPath()
        bezierPath.appendArc(withCenter: NSPoint(x: radius, y: frame.height - radius), radius: radius, startAngle: 90, endAngle: 180) // Top left corner
        bezierPath.line(to: NSMakePoint(0, radius))
        bezierPath.appendArc(withCenter: NSPoint(x: radius, y: radius), radius: radius, startAngle: 180, endAngle: 270) // Bottom left corner
        bezierPath.line(to: NSMakePoint(frame.width - radius, 0))
        bezierPath.appendArc(withCenter: NSPoint(x: frame.width - radius, y: radius), radius: radius, startAngle: 270, endAngle: 360) // Bottom right corner
        bezierPath.line(to: NSMakePoint(frame.width, frame.height - radius))
        bezierPath.appendArc(withCenter: NSPoint(x: frame.width - radius, y: frame.height - radius), radius: radius, startAngle: 0, endAngle: 90) // Top left corner
        bezierPath.line(to: NSMakePoint(radius, frame.height))

        if self.state == .on {
            
            NSColor(red: 0.25, green: 0.55, blue: 0.75, alpha: 1).setFill()
            bezierPath.fill()

            label.textColor = NSColor.white
            label.stringValue = titleString

        } else {
            
            if mouseIsIn {
                NSColor(red: 0.9, green: 0.95, blue: 1, alpha: 0.6).setFill()
                bezierPath.fill()
            }
            
            label.textColor = NSColor(red: 0.22, green: 0.55, blue: 0.75, alpha: 1)
            label.stringValue = titleString

        }
    }
    
    override var state: NSControl.StateValue {
        didSet {
            self.needsDisplay = true
        }
    }
    
    override func awakeFromNib() {
        label = NSTextField(frame: NSMakeRect(0, 6.5, frame.width, 19))
        label.isBezeled = false
        label.isBordered = false
        label.drawsBackground = false
        label.isEditable = false
        label.font = NSFont(name: "Raleway Light", size: 13)
        label.alignment = .center
        label.lineBreakMode = .byTruncatingMiddle
        addSubview(label)
        self.addTrackingArea(NSTrackingArea(rect: self.bounds, options: NSTrackingArea.Options(rawValue: 129), owner: self, userInfo: nil))
    }
    
    var mouseIsIn = false
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)

        mouseIsIn = true
        self.needsDisplay = true
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        mouseIsIn = false
        self.needsDisplay = true
    }
    
}
