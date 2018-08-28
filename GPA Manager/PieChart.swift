//
//  PieChart.swift
//  GPA Manager
//
//  Created by Jia Rui Shan on 27/05/2017.
//  Copyright © 2017 Jerry Shan. All rights reserved.
//

import Cocoa

let disabledColor = NSColor(white: 0.75, alpha: 0.9)

class PieChart: NSView {
    
    @IBOutlet weak var percentageTitle: NSTextField!
    @IBOutlet weak var descriptionSubtitle: NSTextField!
    
    let subtitles = [
        "No grades available. To calculate grades, please add an assignment.",
        "With this grade, you will not pass the IB Diploma program.",
        "Try harder! Getting 3 should be pretty easy...",
        "This is the minimum passing grade. You have a long way to go...",
        "Good job! The IB diploma is tough. Have faith in yourself and you will succeed.",
        "You are nearly there! 6 is definitely a decent grade.",
        "Well done! You are already a 7 in this subject. Keep it up!"
    ]
    
    var title = "" {
        didSet {
            percentageTitle.stringValue = title
        }
    }
    
    var subtitle = "" {
        didSet {
            descriptionSubtitle.stringValue = subtitle
        }
    }

    var values = [CGFloat]() {
        didSet {
            var total: CGFloat = 0
            for i in values {
                total += i
            }
            if total == 1 && names.count == values.count {
                self.needsDisplay = true
            }
        }
    }
    
    var names = [String]() {
        didSet {
            var total: CGFloat = 0
            for i in values {
                total += i
            }
            if total == 1 && names.count == values.count {
                self.needsDisplay = true
            }

        }
    }
    
    var thickness: CGFloat {
        return self.frame.width / 35
    }
    
    var innerLayerWidth: CGFloat {
        return thickness * 0.4
    }
    
    var gapBetweenTasks: CGFloat = 0.4
    
    var sectorColors = [
        NSColor(red: 249/255, green: 210/255, blue: 213/255, alpha: 1),
        NSColor(red: 178/255, green: 230/255, blue: 78/255, alpha: 1),
        NSColor(red: 186/255, green: 166/255, blue: 253/255, alpha: 1),
        NSColor(red: 64/255, green: 125/255, blue: 230/255, alpha: 1),
        NSColor(red: 90/255, green: 220/255, blue: 139/255, alpha: 1),
        NSColor(red: 1, green: 224/255, blue: 97/255, alpha: 1),
        NSColor(red: 128/255, green: 206/255, blue: 245/255, alpha: 1),
        NSColor(red: 1, green: 192/255, blue: 114/255, alpha: 1),
    ]
    
    subscript(leftEdge: Int) -> CGFloat {
        var distance: CGFloat = 0
        if leftEdge == -1 {return 0}
        for i in 0...leftEdge {
            distance += values[i]
        }
        return distance
    }
    
    var center: NSPoint {
        return NSPoint(x: self.frame.width / 2, y: self.frame.height / 2)
    }
    
    override func awakeFromNib() {
        self.addTrackingArea(NSTrackingArea(rect: self.bounds, options: NSTrackingAreaOptions(rawValue: 131), owner: self, userInfo: nil))
    }
    
    var assignments = [(name: String, category: String, score: String, startAngle: CGFloat, endEngle: CGFloat, borderAngle: CGFloat)]()
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        if selectedSubject == "Subjects Overview" {return}
        
        let radius = self.frame.width / 2
        
        var currentAngle: CGFloat = 90
        
        let bezierPath = NSBezierPath()
        bezierPath.lineWidth = thickness
        
        if values.count == 0 {
            bezierPath.appendArc(withCenter: center, radius: radius - thickness, startAngle: currentAngle, endAngle: currentAngle + 360)
            
            disabledColor.setFill()
            disabledColor.set()
            bezierPath.stroke()
        } else {
            assignments.removeAll()
            for i in 0..<values.count {
                
                let currentCategory = names[i]
                
                bezierPath.removeAllPoints()
                bezierPath.appendArc(withCenter: center, radius: radius - thickness, startAngle: currentAngle, endAngle: currentAngle + 360 * values[i])
                
                sectorColors[i].set()
                bezierPath.stroke()
                
                var progress = currentAngle
                
                let categoryAssignments = mainvc!.currentSubject.readableAssignments
                
                var categoryTotal = 0
                for i in categoryAssignments.filter({$0.category == currentCategory}) {
                    categoryTotal += i.total
                }
                
                if categoryTotal > 0 {
                    for a in categoryAssignments.filter({$0.category == currentCategory}) {
                        
                        bezierPath.removeAllPoints()
                        let percentage = CGFloat(a.score) / CGFloat(categoryTotal)
                        let gap = a.score == a.total ? gapBetweenTasks : 0
                        
                        let realScoreStartAngle = progress + gapBetweenTasks / 2
                        let realScoreEndAngle = progress + 360 * values[i] * percentage - gap
                        let potentialScoreEndAngle = progress + 360 * values[i] * CGFloat(a.total) / CGFloat(categoryTotal) - gapBetweenTasks / 2
                        
                        bezierPath.appendArc(withCenter: center, radius: radius - 2 * thickness, startAngle: realScoreStartAngle, endAngle: realScoreEndAngle)
                        let h = HorizontalSlider()
                        h.score = CGFloat(a.score); h.max = CGFloat(a.total)
                        NSColor(red: h.lineColor().redComponent-0.1, green: h.lineColor().greenComponent-0.1, blue: h.lineColor().blueComponent-0.1, alpha: 1).set()
                        bezierPath.lineWidth = innerLayerWidth
                        bezierPath.stroke()
                        
                        bezierPath.removeAllPoints()
                        bezierPath.appendArc(withCenter: center, radius: radius - 2 * thickness, startAngle: realScoreEndAngle, endAngle: potentialScoreEndAngle)
                        NSColor(red: h.lineColor().redComponent-0.1, green: h.lineColor().greenComponent-0.1, blue: h.lineColor().blueComponent-0.1, alpha: 0.3).set()
                        bezierPath.stroke()
                        
                        assignments.append((a.name, a.category, "\r\(a.score)/\(a.total) (\(Int( round (CGFloat(a.score) / CGFloat(a.total) * 100) ))%)", progress-90, progress + 360 * values[i] * percentage - 90, potentialScoreEndAngle - 90))
                        progress += 360 * values[i] * CGFloat(a.total) / CGFloat(categoryTotal)
                    }
                    
                }
                currentAngle += 360 * values[i]

                bezierPath.lineWidth = thickness
            }
            
            
        }
        
        self.removeTrackingArea(self.trackingAreas[0])
        self.addTrackingArea(NSTrackingArea(rect: self.bounds, options: NSTrackingAreaOptions(rawValue: 131), owner: self, userInfo: nil))
    }
    
    override func mouseExited(with event: NSEvent) {
//        (superview?.superview as? SubjectDetailView)?.infoPopover.close()
//        Swift.print("exited")
    }
    
    override func mouseMoved(with event: NSEvent) {
        if values.count == 0 {return}
        let mousePoint = self.convert(event.locationInWindow, from: nil)
        let radius = self.frame.width / 2
        let actualPoint = NSMakePoint(mousePoint.x - radius, mousePoint.y - radius) // Using the center as (0, 0)

        let distanceToCenter = sqrt(pow(actualPoint.x, 2.0) + pow(actualPoint.y, 2))
        
        if distanceToCenter <= radius && distanceToCenter >= radius - 1.5 * thickness {
            
            // First, find the angle of the cursor location (using 12:00 as 0 degrees)
            
            var angle: CGFloat = 0 // Degrees mode
            if actualPoint.x > 0 && actualPoint.y > 0 {
                angle = 270 + 180 / CGFloat.pi * atan(actualPoint.y / actualPoint.x)
            } else if actualPoint.x > 0 {
                angle = 270 - 180 / CGFloat.pi * atan(-actualPoint.y / actualPoint.x)
            } else if actualPoint.y > 0 {
                angle = 180 / CGFloat.pi * atan(-actualPoint.x / actualPoint.y)
            } else {
                angle = 90 + 180 / CGFloat.pi * atan(actualPoint.y / actualPoint.x)
            }
            
            let percentage = angle / 360
            var currentBlock = -1 // Find out which category the user is hovering on
            for i in 0..<values.count {
                if self[i] > percentage {currentBlock = i; break}
            }
            
            let blockCenterAngle = (self[currentBlock] - values[currentBlock] / 2) * 2 * CGFloat.pi
            let centerRadius = radius - thickness
            var blockCenterPoint = NSMakePoint(0, 0)
            if blockCenterAngle > 270 {
                blockCenterPoint.x = centerRadius * cos(blockCenterAngle - CGFloat.pi * 1.5)
                blockCenterPoint.y = centerRadius * sin(blockCenterAngle - CGFloat.pi * 1.5)
            } else if blockCenterAngle > 180 {
                blockCenterPoint.x = centerRadius * cos(CGFloat.pi * 1.5 - blockCenterAngle)
                blockCenterPoint.y = -centerRadius * sin(CGFloat.pi * 1.5 - blockCenterAngle)
            } else if blockCenterAngle > 90 {
                blockCenterPoint.x = -centerRadius * cos(blockCenterAngle - CGFloat.pi / 2)
                blockCenterPoint.y = -centerRadius * sin(blockCenterAngle - CGFloat.pi / 2)
            } else {
                blockCenterPoint.x = -centerRadius * cos(CGFloat.pi / 2 - blockCenterAngle)
                blockCenterPoint.y = centerRadius * sin(CGFloat.pi / 2 - blockCenterAngle)
            }
            
            blockCenterPoint.x += center.x; blockCenterPoint.y += center.y
            
            let locationRect = NSRect(origin: blockCenterPoint, size: NSSize(width: 0.1, height: 0.1))
            (superview!.superview! as! SubjectDetailView).popInfo(title: names[currentBlock], value: values[currentBlock], rect: locationRect)
            
        } else if distanceToCenter <= radius - 0.5 * thickness - (thickness - innerLayerWidth) / 2 && distanceToCenter >= radius - 3 * thickness + (thickness - innerLayerWidth) / 2 {
            var angle: CGFloat = 0 // Degrees mode
            if actualPoint.x > 0 && actualPoint.y > 0 {
                angle = 270 + 180 / CGFloat.pi * atan(actualPoint.y / actualPoint.x)
            } else if actualPoint.x > 0 {
                angle = 270 - 180 / CGFloat.pi * atan(-actualPoint.y / actualPoint.x)
            } else if actualPoint.y > 0 {
                angle = 180 / CGFloat.pi * atan(-actualPoint.x / actualPoint.y)
            } else {
                angle = 90 + 180 / CGFloat.pi * atan(actualPoint.y / actualPoint.x)
            }
            
            var hoveredAssignment: (name: String, category: String, score: String, startAngle: CGFloat, endEngle: CGFloat, borderAngle: CGFloat)?
            
            // Search for the appropriate task that matches the location of the cursor
            for i in assignments {
                if i.borderAngle >= angle && i.startAngle <= angle {
                    hoveredAssignment = i
                    break
                } else {
  
                }
            }
            if hoveredAssignment == nil {return} // User is not hovering on any assignment, stop
            let blockCenterAngle = (hoveredAssignment!.startAngle + hoveredAssignment!.endEngle) / 2 * CGFloat.pi / 180 // Get the angle of the center of the task
            let centerRadius = radius - 2 * thickness // Get the distance between the center and the point
            var blockCenterPoint = NSMakePoint(0, 0)
            if blockCenterAngle > 270 {
                blockCenterPoint.x = centerRadius * cos(blockCenterAngle - CGFloat.pi * 1.5)
                blockCenterPoint.y = centerRadius * sin(blockCenterAngle - CGFloat.pi * 1.5)
            } else if blockCenterAngle > 180 {
                blockCenterPoint.x = centerRadius * cos(CGFloat.pi * 1.5 - blockCenterAngle)
                blockCenterPoint.y = -centerRadius * sin(CGFloat.pi * 1.5 - blockCenterAngle)
            } else if blockCenterAngle > 90 {
                blockCenterPoint.x = -centerRadius * cos(blockCenterAngle - CGFloat.pi / 2)
                blockCenterPoint.y = -centerRadius * sin(blockCenterAngle - CGFloat.pi / 2)
            } else {
                blockCenterPoint.x = -centerRadius * cos(CGFloat.pi / 2 - blockCenterAngle)
                blockCenterPoint.y = centerRadius * sin(CGFloat.pi / 2 - blockCenterAngle)
            }
            
            blockCenterPoint.x += center.x; blockCenterPoint.y += center.y // Get the actual bottom-left coordinates of the point
            
            let locationRect = NSRect(origin: blockCenterPoint, size: NSSize(width: 0.1, height: 0.1))
            (superview!.superview! as! SubjectDetailView).popTaskInfo(title: "\(hoveredAssignment!.name): \(hoveredAssignment!.score)", rect: locationRect) // Trigger the popover
            
        } else {
            (superview?.superview as? SubjectDetailView)?.infoPopover.close() // If the user is not hovering on any content, close the popover
        }
        
    }
    
}
