//
//  OPColorGroup.swift
//  OnePalette
//
//  Created by Joe Manto on 3/6/18.
//  Copyright © 2018 Joe Manto. All rights reserved.
//

import Cocoa
import CoreData

class OPColorGroup: Identifiable, Codable {
    
    private(set) var identifier: String
    var name: String
    var headerColorIndex: Int
    var colorsArray: [OPColor]
    
    var headerColor: OPColor {
        colorsArray[headerColorIndex]
    }
    
    init(id: String) {
        colorsArray = [OPColor]()
        headerColorIndex = 0
        self.name = "blank"
        identifier = id
        self.headerColorIndex = colorsArray.count / 2
    }
    
    func addColor(color: OPColor) {
        colorsArray.append(color)
    }
    
    func sortColorGroupByBrightness() {
        colorsArray = colorsArray.sortedByBrightness()
    }
    
    func findHeaderColor() {
        headerColorIndex = colorsArray.count / 2
    }
    
    /// Sets all color's weights off provided weights
    func updateColorWeights(weights: [Int]) {
        for (i, color) in colorsArray.enumerated() {
            color.setWeight(weight: weights[i])
        }
    }
    
    func description() -> String {
        return "ColorGroup(\(identifier)) - name: \(name) numColors: \(colorsArray.count)"
    }
}

extension OPColorGroup {
    static func newGroup() -> OPColorGroup {
        let group = OPColorGroup(id: UUID().uuidString)
        group.name = "New Group"
        
        group.addColor(color: OPColor.randomGray(weight: 100))
        return group
    }
}

extension [OPColorGroup] {
    
    func sortedByBrightness() -> [OPColorGroup] {
        self.sorted(by: { a, z in
            a.headerColor.lum > z.headerColor.lum
        })
    }
    
    func sortByRainbowColors() -> [OPColorGroup] {
        return self.sorted(by: { a, z in
            let headerA = a.headerColor
            let headerB = z.headerColor
            
            let h1 = Int(headerA.color.hueComponent * 16)
            let l1 = Int(headerA.color.brightnessComponent * 16)
            let s1 = Int(headerA.color.saturationComponent * 8)
            
            let h2 = Int(headerB.color.hueComponent * 16)
            let l2 = Int(headerB.color.brightnessComponent * 16)
            let s2 = Int(headerB.color.saturationComponent * 8)
            
            if h1 != h2 {
                return h1 < h2
            }
            else if l1 != l2 {
                return l1 < l2
            }
            else {
                return s1 < s2
            }
        })
    }
}

extension String {
    
    var firstUppercased: String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }
}
