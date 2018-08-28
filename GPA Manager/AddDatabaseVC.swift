//
//  AddDatabaseVC.swift
//  GPA Manager
//
//  Created by Jia Rui Shan on 31/05/2017.
//  Copyright © 2017 Jerry Shan. All rights reserved.
//

import Cocoa

class AddDatabaseVC: NSViewController, NSTextFieldDelegate {
    
    @IBOutlet weak var databaseName: NSTextField!
    @IBOutlet weak var addButton: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        addButton.isEnabled = false
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        addButton.isEnabled = databaseName.stringValue != "" && !databaseName.stringValue.contains("/")
    }
    
    @IBAction func addDatabase(_ sender: NSButton) {
        
        NSKeyedArchiver.archiveRootObject([[NSObject]](), toFile: mainvc!.dataDir + "/" + databaseName.stringValue)
        mainvc!.reloadDatabasePopUpButton()
        self.dismiss(nil)
    }
    
}
