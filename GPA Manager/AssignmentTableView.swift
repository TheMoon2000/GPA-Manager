//
//  AssignmentTableView.swift
//  GPA Manager
//
//  Created by Jia Rui Shan on 29/05/2017.
//  Copyright © 2017 Jerry Shan. All rights reserved.
//

import Cocoa

class AssignmentTableView: NSTableView {
    
    var currentRow = -1

    override func awakeFromNib() {
        self.addTrackingArea(NSTrackingArea(rect: self.bounds, options: NSTrackingArea.Options(rawValue: 131), owner: self, userInfo: nil))
    }
    
    override func draw(_ dirtyRect: NSRect) {
        self.removeTrackingArea(self.trackingAreas[0])
        self.addTrackingArea(NSTrackingArea(rect: self.bounds, options: NSTrackingArea.Options(rawValue: 131), owner: self, userInfo: nil))
    }
    
    override func mouseMoved(with event: NSEvent) {
        let actualPoint = self.convert(event.locationInWindow, from: nil)
        
        for i in 0..<self.numberOfRows {
            if let cell = self.view(atColumn: 0, row: i, makeIfNecessary: false) as? AssignmentCell {
            
                if i == row(at: actualPoint) {
                    cell.deleteButton.isHidden = false
                    currentRow = i
                } else {
                    cell.deleteButton.isHidden = true
                }
            }
        }

    }
    
    override func mouseExited(with event: NSEvent) {
        for i in 0..<self.numberOfRows {
            let cell = self.view(atColumn: 0, row: i, makeIfNecessary: false) as? AssignmentCell
            cell?.deleteButton?.isHidden = true
            currentRow = -1
        }
    }
    
    func delete(_ row: Int) {
        let alert = NSAlert()
        alert.messageText = "Delete Assignment?"
        alert.informativeText = "This action cannot be undone."
        alert.addButton(withTitle: "Delete Assignment").keyEquivalent = "\r"
        alert.addButton(withTitle: "Cancel")
        alert.icon = NSApplication.shared.applicationIconImage
        alert.beginSheetModal(for: self.window!) {reponse in
            let cell = self.view(atColumn: 0, row: row, makeIfNecessary: false) as! AssignmentCell
            self.removeRows(at: IndexSet(integer: row), withAnimation: .effectFade)
            mainvc!.reloadSubjects = false
            let _ = mainvc!.subjects[selectedSidebarRow-2].assignments[cell.category.title]!.removeValue(forKey: cell.assignmentName)
            mainvc!.reloadSubjects = true
        }
    }
}
