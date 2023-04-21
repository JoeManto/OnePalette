//
//  ColorGroupGridViewModel.swift
//  OnePalette
//
//  Created by Joe Manto on 12/5/22.
//  Copyright © 2022 Joe Manto. All rights reserved.
//

import Foundation

class ColorGroupGridViewModel: ObservableObject {
    
    enum GridSize: Int {
        case small
        case medium
        case large
    }
    
    private let palette: Palette
    private var group: OPColorGroup
    
    var nonHeaderColors: [OPColor] {
        return group.colorsArray.filter { $0.id != group.headerColor.id }
    }
    
    var header: OPColor {
        return group.headerColor
    }
    
    var allColors: [OPColor] {
        return group.colorsArray
    }
    
    let gridSize: GridSize
    
    var name: String {
        group.name
    }
    
    init(palette: Palette, gridSize: GridSize? = nil) {
        self.palette = palette
        
        let lastUsedGroup = palette.paletteData?[palette.curGroupId]
        let firstGroup = palette.paletteData?.first?.value
        
        self.group = lastUsedGroup ?? firstGroup ?? OPColorGroup(id: "Empty")
        
        self.gridSize = gridSize ?? GridSize(size: group.colorsArray.count) ?? .small
    }
    
    func updateToGroup(name: String) {
        if let group = palette.paletteData?[name] {
            self.group = group
        }
    }
}

extension ColorGroupGridViewModel.GridSize {
    init?(size: Int) {
        if size <= 5 {
            self.init(rawValue: Self.small.rawValue)
        }
        else if size < 8 {
            self.init(rawValue: Self.medium.rawValue)
        }
        else {
            self.init(rawValue: Self.large.rawValue)
        }
    }
}
