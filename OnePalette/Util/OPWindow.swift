//
//  OPWindow.swift
//  OnePalette
//
//  Created by Joe Manto on 5/1/18.
//  Copyright © 2018 Joe Manto. All rights reserved.
//

import Cocoa

class OPWindow: NSWindow, NSWindowDelegate {
    
    static let ModifyColorsWindowId = "ModifyColorsWindow"
    
    required init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool, id: String) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        self.delegate = self
        self.identifier = NSUserInterfaceItemIdentifier(id)
        
        if id == Self.ModifyColorsWindowId {
            let x = UserDefaults.standard.double(forKey: "ModifyColors-Origin-X")
            let y = UserDefaults.standard.double(forKey: "ModifyColors-Origin-Y")
            
            self.setFrameOrigin(NSPoint(x: x, y: y))
        }
    }
    
    func windowWillMove(_ notification: Notification) {
        if self.identifier?.rawValue == Self.ModifyColorsWindowId {
            UserDefaults.standard.set(self.frame.origin.x, forKey: "ModifyColors-Origin-X")
            UserDefaults.standard.set(self.frame.origin.y, forKey: "ModifyColors-Origin-Y")
        }
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        return true
    }
    
    func windowWillClose(_ notification: Notification) {
        
    }
}

