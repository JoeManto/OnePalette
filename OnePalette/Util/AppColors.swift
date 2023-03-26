//
//  AppColors.swift
//  OnePalette
//
//  Created by Joe Manto on 3/21/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import SwiftUI

struct DynamicColor {
    let normal: OPColor
    let highlight: OPColor
    
    func highlighting(_ isHighlighted: Bool) -> Color {
        if isHighlighted {
            return Color(highlight.color)
        }
        return Color(normal.color)
    }
}

struct AppColors {
    static let destructive = DynamicColor(normal: OPColor(hexString: "FF3B30", weight: 0), highlight: OPColor(hexString: "FC5E56", weight: 0))
    static let gray1 = DynamicColor(normal: OPColor(hexString: "C7C7CC", weight: 0), highlight: OPColor(hexString: "DEDEDE", weight: 0))
}
