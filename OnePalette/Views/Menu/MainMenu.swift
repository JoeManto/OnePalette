//
//  MainMenu.swift
//  OnePalette
//
//  Created by Joe Manto on 4/20/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import AppKit

class MainMenu: NSMenu {
    
    func build() {
        self.addItem(NSMenuItem(title: "Color Group Actions", action: nil, keyEquivalent: ""))
        self.addItem(NSMenuItem(title: "Add/Modify Colors", action: #selector(AppDelegate.openPaletteModifier(_:)), keyEquivalent: "P"))
        self.addItem(NSMenuItem(title: "Clean Install", action: #selector(AppDelegate.cleanInstall(_:)), keyEquivalent: "P"))
        self.addItem(NSMenuItem.separator())
        self.addItem(NSMenuItem(title: "Selected Color Actions", action: nil, keyEquivalent: ""))
        self.addItem(NSMenuItem(title: "Copy Code For", action: #selector(AppDelegate.placeholder(_:)), keyEquivalent: "P"))
        self.addItem(NSMenuItem(title: "Settings", action: nil, keyEquivalent: ""))
        self.addItem(NSMenuItem(title: "Support", action: nil, keyEquivalent: ""))
        self.addItem(NSMenuItem.separator())
        self.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    }
    
    func showMenu(near location: CGPoint) {
        var newLocation = location
        newLocation.y = NSScreen.main!.frame.height - NSStatusBar.system.thickness - 10
        
        let contentRect = NSRect(origin: newLocation, size: CGSize(width: 0, height: 0))
        
        let tmpWindow = NSWindow(contentRect: contentRect, styleMask: .borderless, backing: .buffered, defer: false)
        tmpWindow.isReleasedWhenClosed = true
        tmpWindow.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.maximumWindow)))
        
        self.popUp(positioning: nil, at: .zero, in: tmpWindow.contentView)
    }
    
}
