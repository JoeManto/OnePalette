//
//  MainMenu.swift
//  OnePalette
//
//  Created by Joe Manto on 4/20/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import AppKit
import AppSDK

class MainMenu: NSMenu {
    
    var formatSelectors = [SelectorAction]()
    
    func build() {
        self.removeAllItems()
        
        self.buildEditor()
        self.buildCopyFormat()
        self.addItem(NSMenuItem.separator())
        self.buildImport()
        self.buildExport()
        self.addItem(NSMenuItem.separator())
        self.buildSettings()
        self.buildSupport()
        self.addItem(NSMenuItem.separator())
        self.buildTrial()
        self.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    }
    
    private func buildCopyFormat() {
        let copy = NSMenuItem(title: "Copy Format", action: nil, keyEquivalent: "")
        self.addItem(copy)
        
        let submenu = NSMenu(title: "Copy Format")
        submenu.addItem(NSMenuItem(title: "Copy Format", action: nil, keyEquivalent: ""))
        submenu.addItem(NSMenuItem.separator())
        
        let item2 = NSMenuItem(title: "Add New Format", action: #selector(AppDelegate.openFormatEditor(_:)), keyEquivalent: "")
        submenu.addItem(item2)
        
        let cur = CopyFormatService.shared.currentFormat
        
        self.formatSelectors.removeAll()
                
        for format in CopyFormatService.shared.formats {
            let selectedImg = NSImage(systemSymbolName: "checkmark", accessibilityDescription: "checkmark")
            
            let action1 = SelectorAction {
                CopyFormatService.shared.setCurrent(format: format)
            }
            
            self.formatSelectors.append(action1)
    
            let item1 = NSMenuItem(title: format.name, action: #selector(action1.action), keyEquivalent: "")
            
            if format.id == cur.id {
                item1.image = selectedImg
            }
            
            item1.target = action1
            submenu.addItem(item1)
        }
        
        self.setSubmenu(submenu, for: copy)
    }
    
    private func buildEditor() {
        self.addItem(NSMenuItem(title: "Open Palette Editor", action: #selector(AppDelegate.openPaletteModifier(_:)), keyEquivalent: ""))
    }
    
    private func buildSettings() {
        let settings = NSMenuItem(title: "Settings", action: nil, keyEquivalent: "")
        self.addItem(settings)
        
        let submenu = NSMenu(title: "Settings")
        submenu.addItem(NSMenuItem(title: "Settings", action: nil, keyEquivalent: ""))
        submenu.addItem(NSMenuItem.separator())
        
        submenu.addItem(NSMenuItem(title: "Clean Install", action: #selector(AppDelegate.cleanInstall(_:)), keyEquivalent: ""))
        
        self.setSubmenu(submenu, for: settings)
    }
    
    private func buildSupport() {
        let support = NSMenuItem(title: "Support", action: nil, keyEquivalent: "")
        self.addItem(support)
        
        let submenu = NSMenu(title: "Support")
        submenu.addItem(NSMenuItem(title: "Support", action: nil, keyEquivalent: ""))
        submenu.addItem(NSMenuItem.separator())
        
        self.setSubmenu(submenu, for: support)
    }
    
    private func buildTrial() {
        self.addItem(NSMenuItem(title: "Purchase", action: #selector(AppDelegate.openTrial(_:)), keyEquivalent: ""))
    }
    
    private func buildImport() {
        let item = NSMenuItem(title: "Import Palette", action: #selector(self.importPalette(_:)), keyEquivalent: "")
        item.target = self
        self.addItem(item)
    }
    
    private func buildExport() {
        let item = NSMenuItem(title: "Export Palette", action: #selector(self.importPalette(_:)), keyEquivalent: "")
        item.target = self
        self.addItem(item)
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
    
    @objc func selectFormat(_ sender: Any?) {
        print("sdf")
    }
    
    @objc func openFormatEditor(_ sender: Any?) {
        
    }
    
    @objc func importPalette(_ sender: Any?) {
        
    }
    
    @objc func exportPalette(_ sender: Any?) {
        
    }

}
