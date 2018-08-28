//
//  AddAssignmentVC.swift
//  GPA Manager
//
//  Created by Jia Rui Shan on 28/05/2017.
//  Copyright © 2017 Jerry Shan. All rights reserved.
//

import Cocoa

class AddAssignmentVC: NSViewController, NSTextFieldDelegate {
    
    @IBOutlet weak var score: NSTextField!
    @IBOutlet weak var total: NSTextField!
    @IBOutlet weak var assignmentName: NSTextField!
    @IBOutlet weak var category: NSPopUpButton!
    @IBOutlet weak var addButton: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        category.addItems(withTitles: mainvc!.currentSubject.categories.keys.map({$0 + " (\(Int(mainvc!.currentSubject.categories[$0]! * 100))%)"}))
    }
    
    @IBAction func selectCategory(_ sender: NSPopUpButton) {
        self.controlTextDidChange(Notification(name: NSNotification.Name(rawValue: ""), object: sender, userInfo: nil))
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        if Int(score.stringValue) == nil || Int(total.stringValue) == nil || assignmentName.stringValue == "" || category.title == "Select a category:" {
            addButton.isEnabled = false
        } else if score.integerValue <= total.integerValue {
            addButton.isEnabled = true
        }
    }
    
    @IBAction func addAssignment(_ sender: NSButton) {
        let categoryName = category.title.components(separatedBy: " (").dropLast().joined(separator: " (")
        var assignments = mainvc!.currentSubject.assignments[categoryName] ?? [String: [Int]]()
        assignments[assignmentName.stringValue] = [total.integerValue, score.integerValue, Int(Date().timeIntervalSince(referenceDate))]
        mainvc!.subjects[selectedSidebarRow-2].assignments[categoryName] = assignments
        self.dismiss(nil)
        mainvc!.subjectDetailView.refreshView()
    }
    
}
