//
//  NSWindow+Util.swift
//  OnePalette
//
//  Created by Joe Manto on 4/19/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import AppKit

extension NSWindow {
    
    enum ScreenQuadrant {
        case topLeft, topRight, bottomLeft, bottomRight
    }
    
    var quadrant: ScreenQuadrant? {
        guard let screen = self.screen?.frame else {
            return nil
        }
        
        let halfScreenWidth = screen.width / 2
        let halfScreenHeight = screen.height / 2
        
        if ((self.frame.origin.x + self.frame.width) / 2) < halfScreenWidth {
            if ((self.frame.origin.y + self.frame.height) / 2) < halfScreenHeight {
                return .bottomLeft
            }
            else {
                return .topLeft
            }
        }
        else {
            if ((self.frame.origin.y + self.frame.height) / 2) < halfScreenHeight {
                return .bottomRight
            }
            else {
                return .topRight
            }
        }
    }
    
    func moveOnScreenIfNeeded() {
        guard let screen = self.screen?.frame else {
            return
        }
        
        // Attempt to the position the window 5 times over a 250 millisecond period
        for update in 0..<5 {
            DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(update * 50))) {
                var newOrigin = NSPoint(x: self.frame.origin.x, y: self.frame.origin.y)
                
                let rightOverlap = (self.frame.origin.x + self.frame.width) - screen.width
                if rightOverlap > 0 {
                    newOrigin.x = screen.width - self.frame.width
                }
                else {
                    let leftOverlap = self.frame.origin.x < 0
                    if leftOverlap {
                        newOrigin.x = 0
                    }
                }
                
                let bottomOverlap = (self.frame.origin.y + self.frame.height) - screen.height
                if bottomOverlap > 0 {
                    newOrigin.y = screen.height - self.frame.height
                }
                else {
                    let topOverlap = self.frame.origin.y < 0
                    if topOverlap {
                        newOrigin.y = 0
                    }
                }

                self.setFrameOrigin(newOrigin)
            }
        }
    }
    
    func moveTopRight() {
        // Attempt to the position the window 5 times over a 250 millisecond period
        for update in 0..<5 {
            DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(update * 50))) {
                guard let screen = NSScreen.main?.frame else {
                    return
                }
                
                let xPosition = screen.width - self.frame.width
                let yPosition = screen.height - self.frame.height
                let origin = CGPoint(x: xPosition, y: yPosition)
                
                print(origin)
                print(self.frame)
                self.setFrameOrigin(origin)
            }
        }
    }
}

