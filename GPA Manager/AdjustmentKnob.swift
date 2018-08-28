//
//  AdjustmentKnob.swift
//  Custom Horizontal Slider
//
//  Created by Jia Rui Shan on 5/25/17.
//  Copyright © 2017 Jerry Shan. All rights reserved.
//

import Cocoa

class AdjustmentKnob: NSView {
    
    var updateView = true
    var pressed = false
    var useKnob = true {
        didSet {
            if !useKnob {
                knobWidth = 0
            }
        }
    }
    
    var values = [CGFloat]() {
        didSet {
            if updateView {self.needsDisplay = true} else {
                if oldValue != values {
                    if #available(OSX 10.11, *) {
                        NSHapticFeedbackManager.defaultPerformer().perform(NSHapticFeedbackPattern.alignment, performanceTime: NSHapticFeedbackPerformanceTime.now)
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
        }
    }
    
    var totalWidth: CGFloat {
        return self.frame.width - knobWidth * CGFloat(values.count - 1)
    }
    
    subscript(leftEdge: Int) -> CGFloat {
        var distance: CGFloat = 0
        if leftEdge == -1 {return 0}
        for i in 0...leftEdge {
            distance += values[i] * totalWidth
            distance += knobWidth
        }
        distance -= knobWidth
        return distance
    }
    
    // Dragging
    var dragging = false
    var currentKnob = -1
    var draggingPosition: CGFloat = 0
    
    // Knob-less dragging
    var leftSide = true
    var distanceToBorder: CGFloat = 0 // How far the cursor position is from either side of the block
    var combinedPortion: CGFloat = 0 // Total percentage of the two view that are currently being adjusted
    
    // Knob
    var knobWidth: CGFloat = 5 {
        didSet {
            self.needsDisplay = true
        }
    }
    var knobColor = NSColor(white: 0.65, alpha: 1) {
        didSet {
            self.needsDisplay = true
        }
    }
    var blockColors = [NSColor]() {
        didSet {
            self.needsDisplay = true
        }
    }
    
    override func awakeFromNib() {
        self.addTrackingArea(NSTrackingArea(rect: self.bounds, options: NSTrackingAreaOptions(rawValue: 131), owner: self, userInfo: nil))
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let thickness = self.frame.height
        
        var currentPosition: CGFloat = 0
        precondition(values.count != 0)
        for i in 0..<values.count - 1 {
            var lengthToAdd = values[i] * totalWidth
            if (self.frame.width - currentPosition - lengthToAdd) - CGFloat(values.count - 1 - i) * knobWidth < 0 {
                lengthToAdd = self.frame.width - currentPosition - CGFloat(values.count - i - 1) * knobWidth
            }
            let startPoint = NSMakePoint(currentPosition, thickness / 2)
            let endPoint = NSMakePoint(currentPosition + lengthToAdd, thickness / 2)
            
            let path = NSBezierPath()
            path.appendPoints(NSPointArray(mutating: [startPoint, endPoint]), count: 2)
            path.lineWidth = thickness
            blockColors[i].set()
            path.stroke()
            
            currentPosition += lengthToAdd
            if useKnob {
                path.removeAllPoints()
                path.appendPoints(NSPointArray(mutating: [NSPoint(x: currentPosition, y: thickness / 2), NSPoint(x: currentPosition + knobWidth, y: thickness / 2)]), count: 2)
                knobColor.set()
                path.stroke()
                currentPosition += knobWidth
            }
        }
        
        let path = NSBezierPath()
        path.appendPoints(NSPointArray(mutating: [NSPoint(x: currentPosition, y: thickness / 2), NSPoint(x: self.frame.width, y: thickness / 2)]), count: 2)
        blockColors.last!.set()
        path.lineWidth = thickness
        path.stroke()
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        if values.count == 0 {dragging = false; return}
        pressed = true
        let actualPoint = self.convert(theEvent.locationInWindow, from: nil)
        if useKnob {
            for i in 0..<values.count {
                if actualPoint.x - self[i] < knobWidth + 2 && actualPoint.x - self[i] >= -2 {
                    dragging = true
                    currentKnob = i
                    draggingPosition = actualPoint.x - self[i]
                    return
                }
            }
        } else {
            var currentPercentage = actualPoint.x / self.frame.width
            
            if values[0] / currentPercentage > 2 || values.last! / (1-currentPercentage) > 2 {dragging = false; return}
            for i in 0..<values.count {
                if currentPercentage > values[i] {
                    currentPercentage -= values[i]
                } else {
                    currentKnob = i
                    leftSide = values[i] / currentPercentage > 2
                    distanceToBorder = leftSide ? currentPercentage : (values[i] - currentPercentage)
                    if leftSide {
                        combinedPortion = values[i] + values[i-1]
                    } else {
                        combinedPortion = values[i] + values[i+1]
                    }
                    dragging = true
                    NSCursor.closedHand().set()
                    return
                }
            }
        }
        dragging = false
    }
    
    var inView = false
    
    override func mouseEntered(with theEvent: NSEvent) {
        inView = true
        self.mouseMoved(with: theEvent)
        if values.count != 0 {
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                NSCursor.openHand().set()
            })
        }
    }
    
    override func mouseExited(with theEvent: NSEvent) {
        inView = false
        NSCursor.arrow().set()
        if !pressed {
            sheetController?.hoverPopover.close()
            hoverLevel = -1
        }
    }

    override func mouseDragged(with theEvent: NSEvent) {
        let actualPoint = self.convert(theEvent.locationInWindow, from: nil)
        
        if !dragging || values.count == 0 {return}
        if useKnob {
            let leftBlockStart: CGFloat = currentKnob == 0 ? 0 : self[currentKnob-1] + knobWidth
            let rightBlockEnd: CGFloat = currentKnob == values.count-1 ? self.frame.width : self[currentKnob+1]
            
            var leftWidth = actualPoint.x - draggingPosition - leftBlockStart
            var rightWidth = rightBlockEnd - (actualPoint.x - draggingPosition + knobWidth)
            
            if rightWidth < 0.01 * totalWidth {
                rightWidth = 0.01 * totalWidth
                leftWidth = rightBlockEnd - leftBlockStart - knobWidth - rightWidth
            } else if leftWidth < 0.01 * totalWidth {
                leftWidth = 0.01 * totalWidth
                rightWidth = rightBlockEnd - leftBlockStart - knobWidth - leftWidth
            }
            
            updateView = false
            values[currentKnob] = leftWidth / totalWidth
            values[currentKnob+1] = rightWidth / totalWidth
            updateView = true
            self.needsDisplay = true
            
        } else {
//            sheetController?.popInfo(NSRect(x: self[currentKnob-1], y: 0, width: values[currentKnob] * totalWidth, height: self.frame.height))
//            sheetController?.hoverPopover.close()
            if !leftSide {
                let blockStart: CGFloat = self[currentKnob-1] // The left edge location of the block being dragged
                
                var leftWidth = (distanceToBorder * totalWidth + actualPoint.x - blockStart) / totalWidth
                if leftWidth < distanceToBorder {leftWidth = distanceToBorder}
                if leftWidth < 0.01 {leftWidth = 0.01}
                leftWidth = round(leftWidth * 100) / 100

                var rightWidth = combinedPortion - leftWidth
                if rightWidth < 0.01 {
                    rightWidth = 0.01
                    leftWidth = combinedPortion - rightWidth
                }
                updateView = false
                values[currentKnob] = leftWidth
                values[currentKnob+1] = rightWidth
                updateView = true
                self.needsDisplay = true
                
                let currentBlockMin = Int( round (blockStart / self.frame.width * 100) ) + 1
                let currentBlockMax = Int( round (blockStart / self.frame.width * 100 + leftWidth * 100 ))
                
                sheetController?.updateText(currentKnob + 1, lvalues: (currentBlockMin, currentBlockMax), rvalues: (Int(blockStart / self.frame.width * 100 + leftWidth * 100) + 1, Int(blockStart / frame.width * 100 + combinedPortion * 100)))
                
                sheetController?.rangePopoverLabel.stringValue = "L\(currentKnob + 1): \(currentBlockMin)-\(currentBlockMax)"
                sheetController?.hover(NSRect(x: blockStart, y: 0, width: leftWidth * self.frame.width, height: self.frame.height))
                
            } else {
                let blockEnd: CGFloat = self[currentKnob] // The right edge of the block being dragged
                
                var rightWidth = (distanceToBorder * totalWidth + blockEnd - actualPoint.x) / totalWidth
                if rightWidth < distanceToBorder {rightWidth = distanceToBorder}
                if rightWidth < 0.01 {rightWidth = 0.01}
                rightWidth = round(rightWidth * 100) / 100
                
                var leftWidth = combinedPortion - rightWidth
                if leftWidth < 0.01 {
                    leftWidth = 0.01
                    rightWidth = combinedPortion - leftWidth
                }
                updateView = false
                values[currentKnob-1] = leftWidth
                values[currentKnob] = rightWidth
                updateView = true
                self.needsDisplay = true
                
                let currentBlockMin = Int( round (blockEnd / self.frame.width * 100 - rightWidth * 100) ) + 1
                let currentBlockMax = Int( round(blockEnd / self.frame.width * 100) )
                
                sheetController?.updateText(currentKnob, lvalues: (Int(blockEnd / self.frame.width * 100 - combinedPortion * 100) + 1, Int(blockEnd / self.frame.width * 100 - rightWidth * 100)), rvalues: (currentBlockMin, currentBlockMax))
                sheetController?.rangePopoverLabel.stringValue = "L\(currentKnob + 1): \(currentBlockMin)-\(currentBlockMax)"
                sheetController?.hover(NSRect(x: blockEnd - rightWidth * self.frame.width, y: 0, width: rightWidth * self.frame.width, height: self.frame.height))

            }
        }
        
    }
    
    var hoverLevel = -1
    
    override func mouseMoved(with theEvent: NSEvent) {
        let actualPoint = self.convert(theEvent.locationInWindow, from: nil)
        for i in 0..<values.count {
            if self[i] > actualPoint.x {
                if i == hoverLevel {return}
                let minValue = Int( round (self[i-1] / self.frame.width * 100) ) + 1
                let maxValue = Int( round (self[i] / self.frame.width * 100) )
                sheetController?.rangePopoverLabel.stringValue = "L\(i+1): \(minValue)-\(maxValue)"
                sheetController?.hover(NSRect(x: self[i-1], y: 0, width: values[i] * self.frame.width, height: self.frame.height))
                hoverLevel = i
                return
            }
        }
    }
    
    override func mouseUp(with theEvent: NSEvent) {
        pressed = false
        dragging = false
        if inView {
            NSCursor.openHand().set()
        } else {
            NSCursor.arrow().set()
            sheetController?.hoverPopover.close()
        }
        Swift.print(values)
        sheetController?.dragPrompt.stringValue = "No area selected."
    }
    
}
