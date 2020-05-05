//
//  ViewController.swift
//  GPA Manager
//
//  Created by Jia Rui Shan on 5/23/17.
//  Copyright © 2017 Jerry Shan. All rights reserved.
//

import Cocoa

var mainvc: ViewController?

var selectedSubject = ""

var selectedSidebarRow = 0

var subjectcount = 0

var settingsMode = false

let referenceDate = Date(timeIntervalSinceReferenceDate: 515376000)
class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSMenuDelegate {
    
    @IBOutlet weak var banner: DragView!
    @IBOutlet weak var splitView: NSSplitView!
    @IBOutlet weak var splitViewLeft: NSView!
    @IBOutlet weak var splitViewRight: NSView!
    
    @IBOutlet weak var gpaIndicator: CircularProgress!
    @IBOutlet weak var gpaNumber: NSTextField!
    @IBOutlet weak var gpaBox: NSView!
    
    @IBOutlet weak var subjectSidebar: NSTableView!
    
    @IBOutlet weak var overviewTable: NSTableView!
    @IBOutlet weak var overviewView: NSView!
    @IBOutlet weak var overviewTitleArea: NSView!
    @IBOutlet weak var overviewBannerTitle: NSTextField!
    @IBOutlet weak var overviewTabBackground: NSView!
    @IBOutlet weak var subjectDetailView: SubjectDetailView!
    @IBOutlet weak var addAssignmentButton: NSButton!
    @IBOutlet weak var addAssignmentPrompt: NSTextField!

    @IBOutlet weak var fileSelection: NSPopUpButton!
    @IBOutlet weak var addSubjectButton: NSButton!
    @IBOutlet weak var settingsButton: NSButton!
    @IBOutlet weak var removeSubjectButton: NSButton!
    
    @IBOutlet weak var assignmentTable: AssignmentTableView!
    
    var constraint = [NSLayoutConstraint]()
    
    var dataPath: String {
        let d = UserDefaults.standard.string(forKey: "File Name") ?? "Default"
        Terminal(launchPath: "/bin/mkdir", arguments: ["-p", NSString(string: "~/Library/Application Support/GPA Manager").expandingTildeInPath]).execUntilExit()
        return NSString(string: "~/Library/Application Support/GPA Manager/\(d)").expandingTildeInPath
    }
    
    var dataDir: String {
        Terminal(launchPath: "/bin/mkdir", arguments: ["-p", NSString(string: "~/Library/Application Support/GPA Manager").expandingTildeInPath]).execUntilExit()
        return NSString(string: "~/Library/Application Support/GPA Manager").expandingTildeInPath
    }
    
    var currentGPA: Int = 0 {
        didSet {
            if currentGPA >= 0 {
                gpaNumber.integerValue = currentGPA
                gpaIndicator.percentage = CGFloat(currentGPA) / 42.0
            } else {
                gpaNumber.stringValue = "n/a"
                gpaIndicator.percentage = 0
            }
        }
    }
    
    var reloadSubjects = true
    var subjects = [Subject]() {
        
        didSet {
            if reloadSubjects {
                subjectcount = subjects.count
                NSKeyedArchiver.archiveRootObject(subjects.map({$0.encodedForm}), toFile: dataPath)
                if subjects.count != oldValue.count {
                    selectedSubject = ""
                    subjects.sort(by: { s0, s1 -> Bool in
//                    $0.0.group < $0.1.group && $0.0.fullname < $0.1.fullname
                        if s0.group != s1.group {
                            return s0.group < s1.group
                        } else {
                            return s0.name < s1.name
                        }
                    })
                    self.subjectSidebar.reloadData()
                }
                assignmentTable.reloadData()
                
                addSubjectButton.isEnabled = subjects.count < 6
                
                var gpaSum = 0
                for i in subjects {
                    if i.scoreOutOf7 == -1 {return} else {
                        gpaSum += i.scoreOutOf7
                    }
                }
                currentGPA = gpaSum
            }
        }
    }
    
    var currentSubject: Subject {
        return subjects.filter({$0.name == selectedSubject})[0]
    }

    
    func windowWillResize() {
        constraint = NSLayoutConstraint.constraints(withVisualFormat: "[firstview(\(splitViewLeft.frame.width))]", options: NSLayoutConstraint.FormatOptions.alignmentMask, metrics: nil, views: ["firstview": splitViewLeft])
        splitViewLeft.addConstraints(constraint)
    }
    
    func windowHasResized() {
        splitViewLeft.removeConstraints(constraint)
    }
    
    override func viewDidAppear() {
        // Important!
        self.view.window!.acceptsMouseMovedEvents = true
        selectedSubject = "Subjects Overview"
        subjectSidebar.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
//        print(subjects)
        print(subjects)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainvc = self
        
        let sidebarNib = NSNib(nibNamed: NSNib.Name(rawValue: "SubjectSideBarView"), bundle: Bundle.main)
        subjectSidebar.register(sidebarNib, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Subject"))
        subjectSidebar.register(sidebarNib, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Label"))
        
        let subjectOverviewNib = NSNib(nibNamed: NSNib.Name(rawValue: "SubjectOverviewCell"), bundle: Bundle.main)
        overviewTable.register(subjectOverviewNib, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Subject Overview"))
        
        let assignmentView = NSNib(nibNamed: NSNib.Name(rawValue: "AssignmentCell"), bundle: Bundle.main)
        assignmentTable.register(assignmentView, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Assignment"))
        
        banner.wantsLayer = true
        banner.layer?.backgroundColor = NSColor(red: 0.3, green: 0.58, blue: 0.78, alpha: 1).cgColor
        
        overviewTabBackground.wantsLayer = true
        overviewTabBackground.layer!.backgroundColor = NSColor(red: 0.82, green: 0.92, blue: 1, alpha: 1).cgColor
        
        overviewTitleArea.wantsLayer = true
        overviewTitleArea.layer!.backgroundColor = NSColor(red: 0.75, green: 0.85, blue: 0.93, alpha: 0.8).cgColor
        
        reloadDatabasePopUpButton()
        initialize()
        
        view.appearance = NSAppearance(named: .aqua)
    }
    
    func reloadDatabasePopUpButton() {
        do {
            let names = try FileManager().contentsOfDirectory(atPath: dataDir).filter({!$0.hasPrefix(".")})
            fileSelection.removeAllItems()
            fileSelection.addItems(withTitles: names)
            if names.count == 0 {
                fileSelection.addItem(withTitle: "Default")
            }
            
            fileSelection.menu?.addItem(NSMenuItem.separator())
            fileSelection.addItem(withTitle: "Add New...")
            
            if let name = UserDefaults.standard.string(forKey: "File Name") { // User manually selected a default database in the past
                if !names.contains(name) { // This selected database no longer exists
                    UserDefaults.standard.set(names.first ?? "Default", forKey: "File Name")
                } else {
                    fileSelection.title = name
                }
            } else { // User has not pick a database before
                UserDefaults.standard.set("Default", forKey: "File Name")
            }
        } catch {}
    }
    
    func menuWillOpen(_ menu: NSMenu) {
       reloadDatabasePopUpButton()
    }
    
    func initialize() {
        
        if FileManager().fileExists(atPath: self.dataPath) {
            let raw = NSKeyedUnarchiver.unarchiveObject(withFile: self.dataPath) as! [[NSObject]]
            self.subjects = raw.map({item -> Subject in
                return Subject(encodedForm: item)
            })
        }
        
        if self.subjects.count == 0 {
            self.currentGPA = -1
        }
        
//        selectedSubject = ""
//        subjectSidebar.deselectAll(nil)
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            
            
//            if self.subjects.count == 0 { self.currentGPA = -1 }
            let _ = self.tableView(self.subjectSidebar, shouldSelectRow: 0)
            self.subjectSidebar.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
            self.tableViewSelectionIsChanging(Notification(name: Notification.Name(rawValue: ""), object: self.subjectSidebar, userInfo: nil))
        }
    }
    
    @IBAction func changeFile(_ sender: NSPopUpButton) {
        if sender.title == "Add New..." {
            self.performSegue(withIdentifier: NSStoryboard.SegueIdentifier(rawValue: "Add Database"), sender: sender)
            sender.title = UserDefaults.standard.string(forKey: "File Name") ?? "Default"
        } else {
            UserDefaults.standard.set(sender.title, forKey: "File Name")
            initialize()
        }
    }
    
    func tableView(_ tableView: NSTableView, shouldTypeSelectFor event: NSEvent, withCurrentSearch searchString: String?) -> Bool {
        return false
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == subjectSidebar {
            return subjects.count + 2
        } else if tableView == overviewTable {
            return subjects.count
        } else {
            return ["", "Subjects Overview"].contains(selectedSubject) ? 0 : currentSubject.readableAssignments.count
        }
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if tableView == subjectSidebar {
            return row == 1 ? 35 : 43
        } else if tableView == overviewTable {
            return 70
        } else {
            return 100
        }
    }

    func tableViewSelectionIsChanging(_ notification: Notification) {
        
        if notification.object as? NSTableView == assignmentTable {return}
        
        if subjectSidebar.selectedRow == -1 && selectedSubject == "" {
            selectedSidebarRow = -1
            selectedSubject = ""
        }
        if selectedSubject != "Subjects Overview" && selectedSubject != "" {
            removeSubjectButton.isEnabled = true
            overviewTable.isHidden = true
            settingsButton.isHidden = false
            addAssignmentButton.isHidden = false
            addAssignmentPrompt.isHidden = false
        } else {
            removeSubjectButton.isEnabled = false
            overviewTable.isHidden = false
            settingsButton.isHidden = true
            addAssignmentButton.isHidden = true
            addAssignmentPrompt.isHidden = true
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableView == subjectSidebar {
            if row == 1 {
                let cell = subjectSidebar.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Label"), owner: self)
                return cell
            } else if row == 0 {
                let cell = subjectSidebar.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Subject"), owner: self) as! SubjectSideBarView
                cell.subjectName.stringValue = "Subjects Overview"
                cell.subjectImage.image = NSImage(named: NSImage.Name(rawValue: "All"))
                return cell
            } else {
                let cell = subjectSidebar.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Subject"), owner: self) as! SubjectSideBarView
                cell.subjectName.stringValue = subjects[row-2].name + (subjects[row-2].hl ? " HL" : " SL")
                cell.subjectImage.image = NSImage(named: NSImage.Name(rawValue: subjects[row-2].name))
                return cell
            }
        } else if tableView == overviewTable {
            let cell = overviewTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Subject Overview"), owner: self) as! SubjectOverviewCell
            cell.subjectImage.image = NSImage(named: NSImage.Name(rawValue: subjects[row].name))
            cell.subjectName.stringValue = subjects[row].fullname
            cell.score.stringValue = subjects[row].scoreOutOf7 == -1 ? "N/A" : "\(subjects[row].scoreOutOf7)/7"
            cell.percentage = subjects[row].percentage
            return cell
        } else {
            let cell = assignmentTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Assignment"), owner: self) as! AssignmentCell
            cell.assignmentName = currentSubject.readableAssignments[row].name
            cell.assignmentNameTextField.stringValue = cell.assignmentName
            cell.category.removeAllItems()
            cell.category.menu?.addItem(withTitle: "Select a category:", action: nil, keyEquivalent: "").isEnabled = false
            cell.category.menu?.addItem(.separator())
            cell.category.addItems(withTitles: Array(currentSubject.categories.keys))
            cell.category.selectItem(withTitle: currentSubject.readableAssignments[row].category)
            cell.categoryName = cell.category.title
            cell.score = currentSubject.readableAssignments[row].score
            cell.total = currentSubject.readableAssignments[row].total
            return cell
        }
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if tableView == overviewTable || tableView == assignmentTable {return true}
        if row > 1 {
            selectedSubject = subjects[row-2].name
            selectedSidebarRow = row
            overviewBannerTitle.stringValue = selectedSubject
            subjectDetailView.isHidden = false
            subjectDetailView.refreshView()
            subjectDetailView.initialize()
            overviewTable.isHidden = true
            assignmentTable.reloadData()
        } else if row == 0 {
            selectedSubject = "Subjects Overview"
            selectedSidebarRow = 0
            overviewTable.isHidden = false
            overviewTable.reloadData()
            overviewBannerTitle.stringValue = "Grade Point Average by Subject"
            subjectDetailView.isHidden = true
            settingsButton.isHidden = true
        }
        return row != 1
    }
    
    func addSubject(_ subject: Subject) {
        selectedSubject = ""
        subjectSidebar.deselectAll(nil)
        var row = -1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
            self.subjects.append(subject)
            for i in 0..<self.subjects.count {
                if self.subjects[i].name == subject.name {row = i + 2; break}
            }
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                let _ = self.tableView(self.subjectSidebar, shouldSelectRow: row)
                self.subjectSidebar.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
                selectedSubject = subject.name
                selectedSidebarRow = row
                self.tableViewSelectionIsChanging(Notification(name: Notification.Name(rawValue: ""), object: self.subjectSidebar, userInfo: nil))
                self.subjectDetailView.refreshView()
            }
        }
    }
    
    @IBAction func removeSubject(_ sender: NSButton) {
        if selectedSidebarRow < 2 {return}
        selectedSubject = ""
        subjects.remove(at: selectedSidebarRow - 2)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            selectedSidebarRow = -1
            let _ = self.tableView(self.subjectSidebar, shouldSelectRow: 0)
            self.subjectSidebar.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
            self.tableViewSelectionIsChanging(Notification(name: Notification.Name(rawValue: ""), object: self.subjectSidebar, userInfo: nil))
        }
        
    }
    
    @IBAction func subjectSettings(_ sender: NSButton) {
        settingsMode = true
        self.performSegue(withIdentifier: NSStoryboard.SegueIdentifier(rawValue: "Subject Settings"), sender: sender)
    }
    
}

class DragView: NSView {
    override var mouseDownCanMoveWindow: Bool {
        return true
    }
}
