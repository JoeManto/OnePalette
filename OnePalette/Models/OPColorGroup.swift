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
    
    var headerColorIndex: Int
    var name: String
    var identifier: String
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
    
    func updateColorWeights(weights: [Int]) {
        for (i, color) in colorsArray.enumerated() {
            color.setWeight(weight: weights[i])
        }
    }
    
    // MARK: Getter & Setters
    
    func getColorArray() -> [OPColor] {
        return self.colorsArray
    }
    
    func getIdentifier() -> String {
        return self.identifier
    }
    
    func getName() -> String {
        return self.name
    }
    
    func setName(name: String) {
        self.name = name
    }
    
    func getHeaderColor() -> OPColor {
        return headerColor
    }
    
    func description()-> String {
        return "ColorGroup(\(identifier)) - name: \(name) numColors: \(colorsArray.count)"
    }
}

extension [OPColorGroup] {
    
    func sortedByBrightness() -> [OPColorGroup] {
        self.sorted(by: { a, z in
            a.headerColor.lum > z.headerColor.lum
        })
    }
}

extension String {
    
    var firstUppercased: String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }
}
