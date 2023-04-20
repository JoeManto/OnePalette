//
//  ScreenContainedPopover.swift
//  OnePalette
//
//  Created by Joe Manto on 4/19/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import AppKit

class ScreenContainedPopover: NSPopover {
    
    private var showingObserver: NSKeyValueObservation?
    private var windowFrameObserver: NSKeyValueObservation?
    
    var startingOrigin: NSPoint?
    
    override init() {
        super.init()
        
        self.showingObserver = self.observe(\.isShown, changeHandler: { [unowned self] (_,_) in
            self.handleShowingChange()
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resetPopoverOrigin() {
        if let origin = startingOrigin {
            self.window?.setFrameOrigin(origin)
        }
        
        if self.isShown {
            //self.window?.moveOnScreenIfNeeded()
            self.window?.moveTopRight()
        }
    }
    
    func handleShowingChange() {
        if self.isShown {
            //self.window?.moveOnScreenIfNeeded()
            self.window?.moveTopRight()
        }
        else {
            resetPopoverOrigin()
        }
    }
}

extension NSPopover {
    var window: NSWindow? {
        self.contentViewController?.view.window
    }
}
