//
//  NSScreen+Util.swift
//  OnePalette
//
//  Created by Joe Manto on 8/21/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import AppKit

extension NSScreen {
    
    func isVisible(window: NSWindow) -> Bool {
        let corners = [
            // Top Left
            NSPoint(x: window.frame.origin.x, y: window.frame.origin.y + window.frame.height),
            // Top Right
            NSPoint(x: window.frame.origin.x + window.frame.width, y: window.frame.origin.y + window.frame.height),
            // Bottom Left
            NSPoint(x: window.frame.origin.x, y: window.frame.origin.y),
            // Bottom Right
            NSPoint(x: window.frame.origin.x + window.frame.width, y: window.frame.origin.y)
        ]
        
        for corner in corners {
            if self.visibleFrame.contains(corner) {
                return true
            }
        }
        
        return false
    }
}
