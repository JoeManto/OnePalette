//
//  OPWindow.swift
//  OnePalette
//
//  Created by Joe Manto on 5/1/18.
//  Copyright © 2018 Joe Manto. All rights reserved.
//

import Cocoa

@MainActor class OPWindow: NSWindow, NSWindowDelegate {
        
    private(set) var prevLocation: NSPoint
    
    required init(contentSize: CGSize, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool, id: String) {
        let x = UserDefaults.standard.double(forKey: "ModifyColors-Origin-X")
        let y = UserDefaults.standard.double(forKey: "ModifyColors-Origin-Y")
        self.prevLocation = NSPoint(x: x, y: y)
        
        super.init(contentRect: NSRect(origin: .zero, size: contentSize), styleMask: style, backing: backingStoreType, defer: flag)
        
        if self.screen?.isVisible(window: self) == false {
            self.prevLocation = NSPoint(x: frame.midX, y: frame.midY)
        }
        
        self.setFrameOrigin(prevLocation)
        self.delegate = self
        self.identifier = NSUserInterfaceItemIdentifier(id)
    }
    
    func windowWillMove(_ notification: Notification) {
        let x = self.frame.origin.x
        let y = self.frame.origin.y
            
        self.prevLocation = NSPoint(x: x, y: y)
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        return true
    }
    
    func windowWillClose(_ notification: Notification) {
        UserDefaults.standard.set(prevLocation.x, forKey: "ModifyColors-Origin-X")
        UserDefaults.standard.set(prevLocation.y, forKey: "ModifyColors-Origin-Y")
    }
}

