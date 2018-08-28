//
//  SubjectDetailView.swift
//  GPA Manager
//
//  Created by Jia Rui Shan on 27/05/2017.
//  Copyright © 2017 Jerry Shan. All rights reserved.
//

import Cocoa

class SubjectDetailView: NSView {
    
    @IBOutlet weak var leftTab: HighlightButton!
    @IBOutlet weak var rightTab: HighlightButton!
    
    @IBOutlet weak var categoryView: NSView!
    @IBOutlet weak var pieChart: PieChart!
    @IBOutlet weak var textView: NSTextView!
    
    @IBOutlet weak var scoresView: NSView!
    
    let infoPopover = NSPopover()
    let popoverVC = NSViewController()

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func viewDidUnhide() {
        super.viewDidUnhide()
        self.addTrackingArea(NSTrackingArea(rect: self.bounds, options: NSTrackingAreaOptions(rawValue: 131), owner: self, userInfo: nil))
    }
    
    var currentSubject: Subject {
        return mainvc!.currentSubject
    }
    
    var titleAttributes: [String: AnyObject] {
        
        let pstyle = NSMutableParagraphStyle()
        pstyle.lineHeightMultiple = 1.5
        pstyle.paragraphSpacingBefore = 5
        pstyle.paragraphSpacing = 12
        
        return [
            NSFontAttributeName: NSFont(name: "Raleway Semibold",size: 16)!,
            NSParagraphStyleAttributeName: pstyle
        ]
    
    }
    
    var contentAttributes: [String: AnyObject] {
        
        let pstyle = NSMutableParagraphStyle()
        pstyle.lineHeightMultiple = 1.3
        pstyle.paragraphSpacing = 8
        
        return [
            NSFontAttributeName: NSFont(name: "Raleway",size: 14)!,
            NSParagraphStyleAttributeName: pstyle
        ]
        
    }
    
    func initialize() {
        
        leftTab.state = 1
        rightTab.state = 0
        
        leftTab.titleString = "Assignment Categories"
        rightTab.titleString = "My Current Scores"
        
        categoryView.isHidden = false
        scoresView.isHidden = true
    }
    
    func refreshView() {
        
        let categories = currentSubject.categories
        pieChart.values = Array(categories.values)
        pieChart.names = Array(categories.keys)
        pieChart.needsDisplay = true

        textView.string = ""
        
        let assignmentsTitle = NSAttributedString(string: "Categories and Weightings:\n", attributes: titleAttributes)
        
        var string = ""
        for i in categories.keys.sorted() {
            string += "\(i): \(Int(categories[i]! * 100))%\n"
        }
        if string == "" {string = "Not Available.\n"}
        
        let weighting = NSAttributedString(string: string, attributes: contentAttributes)
        let scoresTitle = NSAttributedString(string: "Scores:\n", attributes: titleAttributes)
        
        var tasks = ""
        for i in currentSubject.scores.keys.sorted() {
            let percentage = currentSubject.scores[i]! == -1 ? "N/A" : "\(String(format: "%.1f", currentSubject.specificScores[i]!))%"
            tasks += i + ": \(percentage)\n"
        }
        
        if tasks == "" || currentSubject.percentage < 0 {
            tasks = "Not Available."
            pieChart.title = "N/A"
            pieChart.subtitle = "No grade has been added for this subject. Press the add button to begin."
            pieChart.percentageTitle.toolTip = nil
        } else {
            pieChart.title = "\(currentSubject.percentage)%"
            let p = String(format: "%.2f", currentSubject.specificPercentage)
            let nextLevel = currentSubject.scoreOutOf7 == 7 ? "" : "\n\(currentSubject.minPercentageFor(currentSubject.scoreOutOf7+1)-currentSubject.percentage)% needed for a \(currentSubject.scoreOutOf7+1)"
            pieChart.percentageTitle.toolTip = "\(p)%" + nextLevel
            pieChart.subtitle = pieChart.subtitles[currentSubject.scoreOutOf7-1]
        }
        
        let achievements = NSAttributedString(string: tasks, attributes: contentAttributes)
        
        for i in [assignmentsTitle, weighting, scoresTitle, achievements] {
            textView.textStorage?.append(i)
        }
        
        infoPopover.close()
    }
    
    override func mouseMoved(with event: NSEvent) {
        // Convert the coordinate to get the view-based coordinates of the cursor
        let actualPoint = self.convert(event.locationInWindow, from: nil)
        
        // Convert again to get the coordinates in terms of the pie chart
        let piePoint = pieChart.convert(actualPoint, from: self)
        if piePoint.x < 0 || piePoint.y < 0 || piePoint.x > pieChart.frame.width || piePoint.y > pieChart.frame.height {
            if infoPopover.isShown { infoPopover.close()} // If the cursor exists, close any popover
        }
    }

    // Triggered when the user clicks the left tab
    @IBAction func left(_ sender: HighlightButton) {
        leftTab.state = 1
        rightTab.state = 0
        
        categoryView.isHidden = false
        scoresView.isHidden = true
        
        refreshView()
        
    }
    
    // Triggered when user clicks the right tab
    @IBAction func right(_ sender: HighlightButton) {
        leftTab.state = 0
        rightTab.state = 1
        
        categoryView.isHidden = true
        scoresView.isHidden = false
        
        refreshView()
    }
    
    // This function is used to display a popover for a category block (the outer layer of the circle)
    func popInfo(title: String, value: CGFloat, rect: NSRect) {
        
        let percentage = ": \(Int(round(value * 100)))%"
        
        // Programmatically generating an attributed label inside an NSView, which will be displayed in the popover
        
        let size = NSString(string: title + percentage).size(withAttributes: [
            NSFontAttributeName: NSFont(name: "Raleway Medium", size: 13.5)!, // Specify the font
            ])
        let view = NSView(frame: NSRect(x: 0, y: 0, width: size.width + 16, height: size.height + 8))
        let label = NSTextField(frame: NSRect(origin: CGPoint(x:4, y:4), size: NSMakeSize(size.width + 8, size.height)))
        label.isBezeled = false
        label.isBordered = false
        label.drawsBackground = false
        label.lineBreakMode = .byTruncatingMiddle
        label.font = NSFont(name: "Raleway Medium", size: 13.5)
        label.stringValue = title + percentage
        label.isEditable = false
        label.alignment = .center
        view.addSubview(label)
        
        // Configure the popover
        
        popoverVC.view = view
        
        infoPopover.contentViewController = popoverVC
        infoPopover.contentSize = view.frame.size
        infoPopover.animates = false
        infoPopover.behavior = .applicationDefined
        infoPopover.show(relativeTo: rect, of: pieChart, preferredEdge: .maxY)
        
    }
    
    // This function ise used to display a popover for a task-specific grade (the inner layer of the circle)
    func popTaskInfo(title: String, rect: NSRect) {
        
        // Programmatically generating an attributed label inside an NSView, which will be displayed in the popover
        let size = NSString(string: title).size(withAttributes: [
            NSFontAttributeName: NSFont(name: "Raleway Medium", size: 13.5)!, // Specify font
            ]) // Calculate the width and height of the text
        let view = NSView(frame: NSRect(x: 0, y: 0, width: size.width + 16, height: size.height + 8))
        let label = NSTextField(frame: NSRect(origin: CGPoint(x:4, y:4), size: NSMakeSize(size.width + 8, size.height)))
        label.isBezeled = false
        label.isBordered = false
        label.drawsBackground = false
        label.lineBreakMode = .byTruncatingMiddle
        label.font = NSFont(name: "Raleway Medium", size: 13.5)
        label.stringValue = title
        label.isEditable = false
        label.alignment = .center
        view.addSubview(label)
        
        // Configure the popover
        
        popoverVC.view = view
        
        infoPopover.contentViewController = popoverVC
        infoPopover.contentSize = view.frame.size
        infoPopover.animates = false
        infoPopover.behavior = .applicationDefined
        infoPopover.show(relativeTo: rect, of: pieChart, preferredEdge: .maxY)
        
    }
    
}
