//
//  SubjectOverviewCell.swift
//  GPA Manager
//
//  Created by Jia Rui Shan on 5/24/17.
//  Copyright © 2017 Jerry Shan. All rights reserved.
//

import Cocoa

class SubjectOverviewCell: NSTableCellView {

    @IBOutlet weak var subjectName: NSTextField!
    @IBOutlet weak var subjectPercentage: NSTextField!
    @IBOutlet weak var subjectImage: NSImageView!
    @IBOutlet weak var score: NSTextField!
    
    var percentage = 0 {
        didSet {
            subjectPercentage.stringValue = percentage <= -1 ? "N/A" : "\(percentage)%"
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        self.wantsLayer = true
        self.layer!.backgroundColor = NSColor(white: 1, alpha: 0.7).cgColor
    }
    
}
