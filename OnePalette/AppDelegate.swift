//
//  AppDelegate.swift
//  OnePalette
//
//  Created by Joe Manto on 3/1/18.
//  Copyright © 2018 Joe Manto. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    let popover = NSPopover()
    var colorViewController=ColorViewerController.freshController
    let menu = NSMenu()
    var eventMonitor: EventMonitor?
    var colorWindow:OPWindow!
    var colorWindowController: NSWindowController!
    var colorOptionsViewController:OPViewController!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        //let managedContext = persistentContainer.viewContext
        //let entity = NSEntityDescription.entity(forEntityName: "Pal", in: managedContext)
        
        constructMenu()
        statusItem.button?.image = NSImage(named:NSImage.Name("StatusBar"))
        statusItem.button?.action = #selector(iconClicked(sender:))
        statusItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        
        popover.contentViewController = colorViewController()
        
        colorOptionsViewController = NSStoryboard(name:NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "OPViewController")) as! OPViewController
        colorOptionsViewController.colorGroupViewDelegate = popover.contentViewController as! ColorViewerController
        _  = colorOptionsViewController.colorGroupViewDelegate.loadRequiredPalettes()
        
        self.colorWindow = OPWindow(contentRect: NSMakeRect(0, 0, 450, 500), styleMask: [.closable,.miniaturizable,.titled], backing: .buffered, defer: false)
        self.colorWindow.isMovableByWindowBackground = true
        self.colorWindow.center()
        self.colorWindow.isOpaque = false
        self.colorWindow.title = "Modify Colors"
        self.colorWindow.backgroundColor = NSColor.clear
        self.colorWindow.invalidateShadow()
        colorWindowController = MainWindowController(window: colorWindow)
        colorWindowController.window?.contentViewController = colorOptionsViewController
        
        hideController(controller: colorOptionsViewController)
        
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) {
            [weak self] event in if let strongSelf = self, strongSelf.popover.isShown {
                strongSelf.closePopover(sender: event)
            }
        }
    }
    
    func showController(of type:Int){
        switch(type){
        case 0:
            colorWindowController.window?.makeKeyAndOrderFront(self)
            NSApp.activate(ignoringOtherApps: true)
            break;
        default: break
        }
    }
    func hideController(controller:NSViewController){
        colorWindow.orderOut(controller)
    }
    
    func constructMenu() {
        menu.addItem(NSMenuItem(title: "Color Group Actions", action:nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Add/Modify Colors", action: #selector(AppDelegate.addColors(_:)), keyEquivalent: "P"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Selected Color Actions", action:nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Copy Code For", action: #selector(AppDelegate.printQuoteClicked(_:)), keyEquivalent: "P"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Palette Actions", action:nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "New Palette", action: #selector(AppDelegate.printQuoteClicked(_:)), keyEquivalent: "P"))
        menu.addItem(NSMenuItem(title: "Delete Palette", action: #selector(AppDelegate.printQuoteClicked(_:)), keyEquivalent: "P"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    }
    
    //if the statusItem is clicked
    @objc func iconClicked(sender:NSStatusItem){
        let event = NSApp.currentEvent!
        if event.type == NSEvent.EventType.rightMouseUp{
            closePopover(sender:nil)
            statusItem.menu = menu;
            statusItem.popUpMenu(menu)
            statusItem.menu = nil;
        }else{
            toggle(nil)
        }
        
    }
   @objc func printQuoteClicked(_ sender: Any?) {
        print(printQuoteClicked);
    
    }
    
    /*Menu button that shows the OptionsView and configures that view to show the correct display*/
    @objc func addColors(_ sender:Any?){
        let pal:Palette = colorOptionsViewController.colorGroupViewDelegate.curPal!
        let curColorGroup = pal.paletteData![pal.paletteKey![pal.curGroupIndex]]
        
        if !colorOptionsViewController.isViewConfigred {
            colorOptionsViewController.configColorGroupSelectors(colorgroups:pal.paletteData!,keys:pal.paletteKey!)
            colorOptionsViewController.configColorView(colorgroup:curColorGroup!)
        }
        showController(of:0)
    }
    
    //Shows or hides the popover
    func toggle(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender: sender)
            eventMonitor?.stop()
        } else {
            eventMonitor?.start()
            showPopover(sender: sender)
        }
    }
    
    //Shows the popover
    func showPopover(sender: Any?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.maxX)
       }
    }
    
    //Removes the popover
    func closePopover(sender: Any?) {
        popover.performClose(sender)
    }
    

    
    
    
    
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "OnePalette")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
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
            if(!context.hasChanges){ try context.save()}
            print("saved pal on close")
        } catch {
            let nserror = error as NSError

            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(nserror)
            if (result) {
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

