//
//  AssignmentCell.swift
//  GPA Manager
//
//  Created by Jia Rui Shan on 28/05/2017.
//  Copyright © 2017 Jerry Shan. All rights reserved.
//

import Cocoa

class AssignmentCell: NSTableCellView, NSTextFieldDelegate, NSMenuDelegate {
    
    @IBOutlet weak var background: NSView!
    @IBOutlet weak var assignmentNameTextField: NSTextField!
    @IBOutlet weak var bar: HorizontalSlider!
    @IBOutlet weak var scoreTextField: NSTextField!
    @IBOutlet weak var totalTextField: NSTextField!
    @IBOutlet weak var category: NSPopUpButton!
    @IBOutlet weak var deleteButton: NSButton!
    
    var assignmentName = ""
    var categoryName = ""
    
    var score = 0 {
        didSet {
            if scoreTextField.integerValue != score || oldValue != totalTextField.integerValue  {
                scoreTextField.integerValue = score
                bar.score = CGFloat(score)
            }
        }
    }
    
    var total = 0 {
        didSet {
            if totalTextField.integerValue != total || oldValue != totalTextField.integerValue {
                totalTextField.integerValue = total
                bar.max = CGFloat(total)
            }
        }
    }
    
    override func awakeFromNib() {
        background.wantsLayer = true
        background.layer!.cornerRadius = 8
        background.layer!.backgroundColor = NSColor.white.cgColor
        scoreTextField.delegate = self
        totalTextField.delegate = self
        assignmentNameTextField.delegate = self
    }
    
    var currentObject = NSTextField()
    
    override func controlTextDidBeginEditing(_ obj: Notification) {
        currentObject = obj.object as! NSTextField
    }
    
    override func controlTextDidEndEditing(_ obj: Notification) {

        if obj.object as? NSTextField == assignmentNameTextField && assignmentName != assignmentNameTextField.stringValue {
            mainvc!.reloadSubjects = false
            let data = mainvc!.subjects[selectedSidebarRow-2].assignments[category.title]!.removeValue(forKey: assignmentName)
            assignmentName = assignmentNameTextField.stringValue
            mainvc!.subjects[selectedSidebarRow-2].assignments[category.title]![assignmentName] = data!
            mainvc!.reloadSubjects = true
        } else if obj.object as? NSTextField == scoreTextField || obj.object as? NSTextField == totalTextField {
            score = scoreTextField.integerValue
            mainvc!.reloadSubjects = false
            mainvc!.subjects[selectedSidebarRow-2].assignments[category.title]![assignmentName]![1] = score
            total = totalTextField.integerValue
            mainvc!.subjects[selectedSidebarRow-2].assignments[category.title]![assignmentName]![0] = total
            mainvc!.reloadSubjects = true
        }
        
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        self.controlTextDidEndEditing(Notification(name: Notification.Name(rawValue: ""), object: currentObject, userInfo: nil))
    }
    
    @IBAction func changeCategory(_ sender: NSPopUpButton) {
        if sender.title != categoryName {
            mainvc!.reloadSubjects = false
            let data = mainvc!.subjects[selectedSidebarRow-2].assignments[categoryName]!.removeValue(forKey: assignmentName)
            mainvc!.reloadSubjects = true
            mainvc!.subjects[selectedSidebarRow-2].assignments[sender.title]![assignmentName] = data!
            categoryName = sender.title
        }
    }
    
    @IBAction func deleteRow(_ sender: NSButton) {
        mainvc!.assignmentTable.delete(mainvc!.assignmentTable.currentRow)
    }
}
