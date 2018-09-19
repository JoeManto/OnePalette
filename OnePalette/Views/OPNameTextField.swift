//
//  OPNameTextField.swift
//  OnePalette
//
//  Created by Joe Manto on 6/12/18.
//  Copyright © 2018 Joe Manto. All rights reserved.
//

import Cocoa
class OPNameTextField: NSTextField{
    
     init(frameRect: NSRect) {
        super.init(frame: frameRect)
        self.stringValue = ""
        configTextField()

    }
    convenience init(frameRect: NSRect,name: String) {
        self.init(frameRect:frameRect)
        self.stringValue = name
        configTextField()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

    }
    private func configTextField(){
        self.placeholderString = "Group Name"
        self.isEditable = true
        self.isBordered = false
        self.isBezeled = false
        self.focusRingType = NSFocusRingType.none
        self.tag = 4
        self.textColor = NSColor.black
        self.window?.makeFirstResponder(nil)
    }
}
