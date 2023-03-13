//
//  Font+Standard.swift
//  OnePalette
//
//  Created by Joe Manto on 3/9/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import SwiftUI

extension Font {
    static func standardFont(size: CGFloat, relativeTo: TextStyle) -> Font {
        Font.custom("Avenir Next", size: size, relativeTo: relativeTo)
    }
    
    static func standardFontMedium(size: CGFloat, relativeTo: TextStyle) -> Font {
        Font.custom("Avenir Next Medium", size: size, relativeTo: relativeTo)
    }
    
    static func standardFontBold(size: CGFloat, relativeTo: TextStyle) -> Font {
        Font.custom("Avenir Next Bold", size: size, relativeTo: relativeTo)
    }
}
