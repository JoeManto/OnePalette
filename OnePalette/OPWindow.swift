//
//  OPWindow.swift
//  OnePalette
//
//  Created by Joe Manto on 5/1/18.
//  Copyright © 2018 Joe Manto. All rights reserved.
//

import Cocoa

class OPWindow: NSWindow,NSWindowDelegate {
    
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        print("changed window")
        return true
    }
    func windowWillClose(_ notification: Notification) {
        
    }
}

