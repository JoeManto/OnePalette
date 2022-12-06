//
//  ColorGroupGridViewModel.swift
//  OnePalette
//
//  Created by Joe Manto on 12/5/22.
//  Copyright © 2022 Joe Manto. All rights reserved.
//

import Foundation

class ColorGroupGridViewModel: ObservableObject {
    private let palette: Palette
    private var group: OPColorGroup
    
    var nonHeaderColors: [OPColor] {
        return group.getColorArray().filter { $0.id != group.getHeaderColor().id }
    }
    
    var header: OPColor {
        return group.getHeaderColor()
    }
    
    var name: String {
        group.getName()
    }
    
    init(palette: Palette) {
        self.palette = palette
        
        let lastUsedGroup = palette.paletteData?[palette.curGroupId]
        let firstGroup = palette.paletteData?.first?.value
        
        self.group = lastUsedGroup ?? firstGroup ?? OPColorGroup(id: "Empty")
    }
    
    func updateToGroup(name: String) {
        if let group = palette.paletteData?[name] {
            self.group = group
        }
    }
}
