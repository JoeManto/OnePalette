//
//  NSColor+Util.swift
//  OnePalette
//
//  Created by Joe Manto on 12/4/22.
//  Copyright © 2022 Joe Manto. All rights reserved.
//

import Foundation
import AppKit

struct CodeableColor: Codable {
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
    var alpha: CGFloat
    
    var nsColor: NSColor {
        NSColor(red: self.red, green: self.green, blue: self.blue, alpha: self.alpha)
    }
    
    init(from color: NSColor) {
        var comps = [CGFloat](repeating: 0.0, count: color.numberOfComponents)
        color.getComponents(&comps)
    
        self.red = comps[0]
        self.green = comps[1]
        self.blue = comps[2]
        self.alpha = comps[3]
    }
}
