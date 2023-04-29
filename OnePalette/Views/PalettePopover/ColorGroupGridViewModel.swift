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
        case empty
        case small
        case medium
        case large
    }
    
    private let palette: Palette
    @Published var group: OPColorGroup
    
    var nonHeaderColors: [OPColor] {
        return group.colorsArray.filter { $0.id != group.headerColor.id }
    }
    
    var header: OPColor? {
        guard group.headerColorIndex < group.colorsArray.count else {
            return nil
        }
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
        let group = lastUsedGroup ?? firstGroup ?? OPColorGroup(id: "Empty")
        
        self.group = group
        self.gridSize = gridSize ?? GridSize(size: group.colorsArray.count) ?? .small
    }
    
    func updateToGroup(id: String) {
        if let group = palette.paletteData?[id] {
            self.group = group
        }
    }
}

extension ColorGroupGridViewModel.GridSize {
    init?(size: Int) {
        if size == 0 {
            self.init(rawValue: Self.empty.rawValue)
        }
        else if size <= 5 {
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
