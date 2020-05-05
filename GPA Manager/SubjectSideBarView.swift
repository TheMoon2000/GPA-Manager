//
//  SubjectSideBarView.swift
//  GPA Manager
//
//  Created by Jia Rui Shan on 5/23/17.
//  Copyright © 2017 Jerry Shan. All rights reserved.
//

import Cocoa

let selectionBlueColor = NSColor(red: 0.3, green: 0.56, blue: 0.8, alpha: 1)
let selectionLightBlueColor = NSColor(red: 0.36, green: 0.62, blue: 0.86, alpha: 1)

let whiteImages = [
"Economics",
"Business & Management",
"Chemistry",
"Computer Science",
"Music",
//"Biology",
"Physics",
"Psychology",
"Computer Science"]

class SubjectSideBarView: NSTableCellView {

    @IBOutlet weak var subjectImage: NSImageView!
    @IBOutlet weak var subjectName: NSTextField!
    
    var realSubjectName: String {
        if subjectName.stringValue == "Subjects Overview" {return "Subjects Overview"}
        var name = subjectName.stringValue.components(separatedBy: " ")
        name.removeLast()
        return name.joined(separator: " ")
    }
    
    override var backgroundStyle: NSView.BackgroundStyle {
        didSet {
            if backgroundStyle == .dark || selectedSubject == realSubjectName {
                
                self.wantsLayer = true
                
                subjectName.textColor = NSColor.white
                var input = CIVector(cgRect: NSMakeRect(0.05,1.18,0,0))
                let alpha = CIVector(cgRect: NSMakeRect(0,1,0,0))
                
                if subjectName.stringValue == "Subjects Overview" {
                    input = CIVector(cgRect: NSMakeRect(1,0.8,0,0))
                } else {
                    if whiteImages.contains(realSubjectName){
                        input = CIVector(cgRect: NSMakeRect(0.16,1.7,0,0))
                    }
                }
                                
                let filter = CIFilter(name: "CIColorPolynomial", withInputParameters: [
                    "inputRedCoefficients": input,
                    "inputGreenCoefficients": input,
                    "inputBlueCoefficients": input,
                    "inputAlphaCoefficients": alpha])!
                
                subjectImage.layerUsesCoreImageFilters = true

                self.subjectImage.wantsLayer = true
                self.subjectImage.layer!.filters = [filter]
                
                if !(self.backgroundStyle == .dark) {
                    self.backgroundStyle = .dark
                    self.layer?.backgroundColor = selectionLightBlueColor.cgColor
                } else {
                    self.layer?.backgroundColor = selectionBlueColor.cgColor
                }
                
                
                for i in 0..<subjectcount {
                    if i + 2 != selectedSidebarRow {
                        rowAtIndex(i + 2)?.backgroundStyle = .light
                    }
                }
                
                if selectedSidebarRow != 0 {rowAtIndex(0)?.backgroundStyle = .light}
                
            } else if backgroundStyle == .light {
                subjectName.textColor = NSColor.black
                self.layer?.backgroundColor = NSColor.clear.cgColor
                self.subjectImage.layer?.filters?.removeAll()
                self.subjectImage.wantsLayer = false
                self.subjectImage.layerUsesCoreImageFilters = false
            }
        }
    }
    
    func rowAtIndex(_ index: Int) -> SubjectSideBarView? {
        return mainvc!.subjectSidebar.view(atColumn: 0, row: index, makeIfNecessary: false) as? SubjectSideBarView
        
    }
}
