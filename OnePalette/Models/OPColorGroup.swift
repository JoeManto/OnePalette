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
    private var name: String
    private var identifier: String
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
        for (i,color) in colorsArray.enumerated() {
            var x = i-1
            while (x >= 0 && (color.calcLum() > colorsArray[x].calcLum())) {
                let temp = colorsArray[x]
                colorsArray[x] = colorsArray[x+1]
                colorsArray[x+1] = temp
                x-=1
            }
        }
    }
    
    func findHeaderColor() {
        headerColorIndex = colorsArray.count / 2
    }
    
    func updateColorWeights(weights:[Int]) {
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
    
    func getName() -> String{
        return self.name
    }
    
    func setName(name: String){
        self.name = name
    }
    
    func getHeaderColor() -> OPColor {
        return headerColor
    }
    
    func description()->String {
        return "ColorGroup:Name " + name
    }
}
extension String {
    var firstUppercased: String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }
}
