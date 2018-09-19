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
        
        if sender.contentViewController is OPViewController{
            sender.contentViewController?.removeFromParentViewController()
            sender.contentViewController?.view.removeFromSuperview()
            
            let appdelegate = NSApplication.shared.delegate as! AppDelegate
            appdelegate.dealocOptionsController()
        }
        self.contentView?.removeFromSuperview()
        
        return true
    }
    func windowWillClose(_ notification: Notification) {
        
    }

}

