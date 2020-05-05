//
//  GPAWindow.swift
//  GPA Manager
//
//  Created by Jia Rui Shan on 5/23/17.
//  Copyright © 2017 Jerry Shan. All rights reserved.
//

import Cocoa

class GPAWindow: NSWindowController, NSWindowDelegate {

    override func windowDidLoad() {
        super.windowDidLoad()
        window?.titlebarAppearsTransparent = true
        window?.isMovableByWindowBackground = true
        window?.titleVisibility = .hidden
        window?.delegate = self
        window?.appearance = NSAppearance(named: .aqua)
    }

    func windowWillStartLiveResize(_ notification: Notification) {
        mainvc?.windowWillResize()
    }
    
    func windowDidEndLiveResize(_ notification: Notification) {
        mainvc?.windowHasResized()
    }
    
    func windowDidResize(_ notification: Notification) {
//        mainvc!.subjectDetailView.refreshView()
    }
    
    func windowWillEnterFullScreen(_ notification: Notification) {
        window?.toolbar?.isVisible = false
    }
    
    func windowDidExitFullScreen(_ notification: Notification) {
        window?.toolbar?.isVisible = true
    }
    
}
