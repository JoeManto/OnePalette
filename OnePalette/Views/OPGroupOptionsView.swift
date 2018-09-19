//
//  OPGroupOptionsView.swift
//  OnePalette
//
//  Created by Joe Manto on 5/24/18.
//  Copyright © 2018 Joe Manto. All rights reserved.
//

import Cocoa

class OPGroupOptionsView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.frame = NSRect(x: 0, y: 0, width: 600, height: 450)
        self.layer?.backgroundColor = NSColor.gray.cgColor
    }
    
}
