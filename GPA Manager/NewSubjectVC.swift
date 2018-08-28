//
//  NewSubjectViewController.swift
//  GPA Manager
//
//  Created by Jia Rui Shan on 5/24/17.
//  Copyright © 2017 Jerry Shan. All rights reserved.
//

import Cocoa

var sheetController: NewSubjectViewController?

class NewSubjectViewController: NSViewController {
    
    @IBOutlet weak var hl: OnOffSwitchControlCell!
    @IBOutlet weak var boundaries: AdjustmentKnob!
//    @IBOutlet weak var popoverView: NSView!
    @IBOutlet weak var dragPrompt: NSTextField!
//    @IBOutlet weak var levelPopoverLabel: NSTextField!
    @IBOutlet weak var hoverView: NSView!
    @IBOutlet weak var rangePopoverLabel: NSTextField!
    @IBOutlet weak var addSubjectButton: NSButton!
    @IBOutlet weak var subjectSelection: NSPopUpButton!
    
    let vc = NSViewController(nibName: "Main", bundle: Bundle.main)!
    
    let dragPopover = NSPopover()
    let hoverPopover = NSPopover()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        sheetController = self
        hl.onSwitchLabel = "HL"
        hl.offSwitchLabel = "SL"
        hl.setOnOffSwitchCustomOn(NSColor(red: 0.3, green: 0.6, blue: 0.82, alpha: 1), offColor: NSColor(red: 0.3, green: 0.82, blue: 0.4, alpha: 1))
        hl.onOffSwitchControlColors = OnOffSwitchControlCustomColors
        
        //Knob
        boundaries.blockColors = [
            NSColor(red: 1, green: 98/255, blue: 96/255, alpha: 1),
            NSColor(red: 1, green: 192/255, blue: 114/255, alpha: 1),
            NSColor(red: 1, green: 224/255, blue: 97/255, alpha: 1),
            NSColor(red: 177/255, green: 226/255, blue: 77/255, alpha: 1),
            NSColor(red: 86/255, green: 220/255, blue: 104/255, alpha: 1),
            NSColor(red: 128/255, green: 206/255, blue: 244/255, alpha: 1),
            NSColor(red: 64/255, green: 125/255, blue: 230/255, alpha: 1),
        ]
        boundaries.values = []
        boundaries.useKnob = false
        
        addSubjectButton.isEnabled = false
        
        subjectSelection.isEnabled = false
        
        if settingsMode {
            subjectSelection.title = selectedSubject
            subjectSelection.isEnabled = false
            let target = mainvc!.subjects.filter({$0.name == selectedSubject})[0]
            boundaries.values = target.boundaries
            hl.objectValue = target.hl
            addSubjectButton.title = "Update Boundaries"
        } else {
            addSubjectButton.title = "Add Subject"
        }
        addSubjectButton.isEnabled = false
        loadBoundariesData()
    }
    
    func realSubjectName(_ subject: String) -> String {
        if subject == "Subjects Overview" {return "Subjects Overview"}
        var name = subject.components(separatedBy: " ")
        name.removeLast()
        return name.joined(separator: " ")
    }
    
    func sum(_ array: [Double]) -> Bool {
        var sum: Double = 0
        for i in array {
            sum += i
        }
        return sum == 100
    }
    
    func loadBoundariesData() {
        
        let url = URL(string: "http://tenic.xyz/tenicCore/GPA%20Boundaries.php")!
        let task = URLSession.shared.dataTask(with: url, completionHandler: {
        data, response, error in
            if error != nil || data == nil {
                print(error ?? "unknown error")
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSArray
                if let tmp = json as? [[String]] {
                    for i in tmp {
                        subjectBoundaries[i[0]] = i[1].components(separatedBy: " | ").map({CGFloat(Double($0)!)})
                        if i[2] != "" && self.sum(i[3].components(separatedBy: " | ").map({Double($0)! * 100})) {
                            subjectCategories[i[0]] = (categories: i[2].components(separatedBy: " | "), weightings: i[3].components(separatedBy: " | ").map({CGFloat(Double($0)!)}))
                        } else if i[2] != "" {
                            Swift.print(i[3].components(separatedBy: " | ").map({Double($0)! * 100}))
                        }
                    }
                    DispatchQueue.main.async {
                        if !settingsMode {
                            self.subjectSelection.isEnabled = true
                        }
                        self.addSubjectButton.isEnabled = true
                        settingsMode = false
                    }
                }
            } catch let err as NSError {
                print(err)
            }
        })
        task.resume()
    }
    
    @IBAction func chooseSubject(_ sender: NSPopUpButton) {
        addSubjectButton.isEnabled = true
        let fullName = sender.title + (hl.state == 1 ? " HL" : " SL")
        if let b = subjectBoundaries[fullName] {
            boundaries.values = b
        }
        if SL_Only.contains(sender.title) {
            hl.isEnabled = false
            hl.state = 0
        } else {
            hl.isEnabled = true
        }
    }
    
    
    @IBAction func switchLevel(sender: NSButton) {
        let fullName = subjectSelection.title + (hl.state == 1 ? " HL" : " SL")
        if let b = subjectBoundaries[fullName] {
            boundaries.values = b
        }
    }

    var sentinel = (min: 0, max: 0)
    
    func updateText(_ left: Int, lvalues: (min: Int, max: Int), rvalues: (min: Int, max: Int)) {
        if rvalues.min == sentinel.min && rvalues.max == sentinel.max {return}
        dragPrompt.stringValue = "Level \(left): \(lvalues.min) - \(lvalues.max) | Level \(left+1): \(rvalues.min) - \(rvalues.max)"
        sentinel = rvalues
    }
    
    func hover(_ bounds: NSRect) {
        vc.view = hoverView
        hoverPopover.contentViewController = vc
        hoverPopover.animates = false
        hoverPopover.behavior = .applicationDefined
        hoverPopover.show(relativeTo: bounds, of: boundaries, preferredEdge: .maxY)
    }
    
    @IBAction func addSubject(_ sender: NSButton) {
        let fullTitle = subjectSelection.title + (hl.state == 1 ? " HL" : " SL")
        if sender.title == "Add Subject" {
            var cDict = [String: CGFloat]()
            if let c = subjectCategories[fullTitle] {
                for i in 0..<c.categories.count {
                    cDict[c.categories[i]] = c.weightings[i]
                }
            }
            
            var aDict = [String: [String: [Int]]]()
            
            for i in cDict.keys {
                aDict[i] = [:]
            }
            
            mainvc!.addSubject(Subject(name: subjectSelection.title, group: subjectSelection.selectedTag(), categories: cDict, hl: hl.state == 1, assignments: aDict, boundaries: boundaries.values))
            self.dismiss(sender)
            Swift.print(cDict)
        } else {
            mainvc!.subjects[selectedSidebarRow-2].boundaries = boundaries.values
            if subjectCategories[fullTitle] != nil {
                var categories = [String: CGFloat]()
                for i in 0..<subjectCategories[fullTitle]!.categories.count {
                    categories[subjectCategories[fullTitle]!.categories[i]] = subjectCategories[fullTitle]!.weightings[i]
                }
                mainvc!.subjects[selectedSidebarRow-2].categories = categories
                mainvc!.subjectDetailView.refreshView()
            }
            self.dismiss(nil)
        }
    }
}

var subjectBoundaries = [String: [CGFloat]]()
let SL_Only = ["Mathematical Studies", "Spanish Ab", "Chinese Ab"]

var subjectCategories = [String: (categories: [String], weightings: [CGFloat])]()
