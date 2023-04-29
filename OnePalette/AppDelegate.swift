//
//  AppDelegate.swift
//  OnePalette
//
//  Created by Joe Manto on 3/1/18.
//  Copyright © 2018 Joe Manto. All rights reserved.
//

import Cocoa
import AppSDK
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    let popover = ScreenContainedPopover()

    private let menu = MainMenu()
    private var eventMonitor: EventMonitor?
    
    var colorWindow: OPWindow!
    private var colorWindowController: NSWindowController!
    
    var copyFormatWindow: OPWindow!
    private var copyFormatWindowController: NSWindowController!
    
    var trialWindow: NSWindow!
    private var trialWindowController: NSWindowController!
    
    private var optionViewIsConfiged = false
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        PaletteService.shared.onPalettesFetched {
            self.setup()
            self.setupNotifications()
        }
    }
    
    // MARK: Window and Application Lifecycle
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func hideController(window: NSWindow, controller: NSViewController) {
        window.orderOut(controller)
    }
    
    // MARK: Setup
    
    func setup() {
        statusItem.button?.image = NSImage(named: NSImage.Name("StatusBar"))
        statusItem.button?.action = #selector(iconClicked(sender:))
        statusItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
                
        self.colorWindow = OPWindow(contentRect: NSMakeRect(0, 0, 450, 500), styleMask: [.closable, .miniaturizable, .titled], backing: .buffered, defer: false, id: "ModifyColorsWindow")
        self.colorWindow.isOpaque = false
        self.colorWindow.isReleasedWhenClosed = true
        self.colorWindow.title = "Modify Colors"
        self.colorWindow.backgroundColor = NSColor.clear
        self.colorWindow.invalidateShadow()
        
        self.colorWindowController = MainWindowController(window: self.colorWindow)
        
        self.copyFormatWindow = OPWindow(contentRect: NSMakeRect(0, 0, 450, 500), styleMask: [.closable, .miniaturizable, .titled], backing: .buffered, defer: false, id: "Copy-Format-Editor")
        self.copyFormatWindow.isOpaque = false
        self.copyFormatWindow.isReleasedWhenClosed = true
        self.copyFormatWindow.title = "Copy Format Editor"
        self.copyFormatWindow.backgroundColor = NSColor.clear
        self.copyFormatWindow.invalidateShadow()
        
        self.copyFormatWindowController = MainWindowController(window: self.copyFormatWindow)
      
        // Tracks left and right clicks on status item
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown], isLocal: false) { [weak self] event in
            if let strongSelf = self, strongSelf.popover.isShown {
                strongSelf.closePopover(sender: event)
            }
        }
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(forName: PaletteService.nextPaletteNavigationNotification.name, object: nil, queue: .main, using: { [unowned self] _ in
            self.popover.window?.moveTopRightRepeatedly()
        })
        
        NotificationCenter.default.addObserver(forName: PaletteService.prevPaletteNavigationNotification.name, object: nil, queue: .main, using: { [unowned self] _ in
            self.popover.window?.moveTopRightRepeatedly()
        })
        
        NotificationCenter.default.addObserver(forName: PaletteService.paletteInstalledNotification.name, object: nil, queue: .main, using: { [unowned self] _ in
            self.closePopover(sender: nil)
        })
    }
    
    // MARK: Popover Controls
    
    /// Shows or hides the popover
    func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender: sender)
            eventMonitor?.stop()
        }
        else {
            eventMonitor?.start()
            closePaletteEditor(sender: sender)
            showPopover(sender: sender)
        }
    }
    
    /// Shows the popover
    func showPopover(sender: Any?) {
        guard let palette = PaletteService.shared.lastUsed else {
            return
        }
        
        self.popover.contentViewController = ColorViewerController(curPal: palette)
        self.popover.showNear(statusItem: self.statusItem)
    }
    
    /// Removes the popover
    func closePopover(sender: Any?) {
        popover.performClose(sender)
    }
    
    func closePaletteEditor(sender: Any?) {
        self.colorWindow.performClose(sender)
    }
    
    // MARK: Selectors
    
    @objc func openPaletteModifier(_ sender: Any?) {
        self.colorWindow.contentViewController = PaletteModifierViewController()
        self.colorWindow.makeKeyAndOrderFront(self)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func openTrial(_ sender: Any?) {
        self.showTrialWindow()
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func openFormatEditor(_ sender: Any?) {
        self.copyFormatWindow.contentViewController = CopyFormatEditorViewController()
        self.copyFormatWindow.makeKeyAndOrderFront(self)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func cleanInstall(_ sender: Any?) {
        closePopover(sender: nil)
        self.colorWindow.orderOut(nil)
        PaletteService.shared.cleanInstall()
        for format in CopyFormatService.shared.formats {
            CopyFormatService.shared.remove(format: format)
        }
    }
    
    @objc func placeholder(_ sender: Any?) {
        print("Place Holder")
    }
    
    /// Handler when the status icon is click. Handles left and right clicks
    @objc func iconClicked(sender: NSStatusItem) {
        let wasRightClick = NSApp.currentEvent?.type == NSEvent.EventType.rightMouseUp
        if wasRightClick {
            closePopover(sender: nil)
            menu.build()
            menu.showMenu(near: NSEvent.mouseLocation)
        }
        else{
            self.togglePopover(nil)
        }
    }
    
    private func showTrialWindow() {
        let img = NSImage(named: NSImage.Name("AppIcon"))
        
        guard trialWindow == nil else {
            trialWindow.makeKeyAndOrderFront(self)
            return
        }
        
        let controller = TrialViewController(rootView: TrialWallView(vm:
                TrialWallViewModel(productModel: TrialProduct(name: "One Palette Trial", options: [
                    PaymentOption(type: .yearly, price: 9.99, recommended: true, trialLength: 7),
                    PaymentOption(type: .monthy, price: 2.99, recommended: false, trialLength: 7),
                    PaymentOption(type: .onetime, price: 30.0, recommended: false, trialLength: 7)
                ], image: img)),
                actionHandler: TrialWallActionHandler(onRestore: {}, onTerms: {}, onContinue: { _ in }
        )))
    
        self.trialWindow = controller.pushToWindow(title: "One Palette Trial", display: true)
    }

    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        // The persistent container for the application. This implementation
        // creates and returns a container, having loaded the store for the
        // application to it. This property is optional since there are legitimate
        // error conditions that could cause the creation of the store to fail.
        let container = NSPersistentContainer(name: "OnePalette")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                // Typical reasons for an error here include:
                // The parent directory does not exist, cannot be created, or disallows writing.
                // The persistent store is not accessible, due to permissions or data protection when the device is locked.
                // The device is out of space.
                // The store could not be migrated to the current model version.
                // Check the error message to determine what the actual problem was.
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving and Undo support
    
    @IBAction func saveAction(_ sender: AnyObject?) {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        let context = persistentContainer.viewContext
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Customize this code block to include application-specific recovery steps.
                let nserror = error as NSError
                NSApplication.shared.presentError(nserror)
            }
        }
    }
    
    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return persistentContainer.viewContext.undoManager
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        let context = persistentContainer.viewContext
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        
        if !context.hasChanges {
            return .terminateNow
        }
        
        do {
            if !context.hasChanges {
                try context.save()
            }
            print("saved pal on close")
        } catch {
            let nserror = error as NSError
            
            // Customize this code block to include application-specific recovery steps.
            if sender.presentError(nserror) {
                return .terminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == .alertSecondButtonReturn {
                return .terminateCancel
            }
        }
        // If we got here, it is time to quit.
        return .terminateNow
    }
}

