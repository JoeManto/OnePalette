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
    
    private var headerColor: OPColor
    var headerColorIndex: Int
    private var name: String
    private var identifier: String
    var colorsArray: [OPColor]
    
    /*func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "groupName")
        aCoder.encode(headerColor, forKey: "headerColor")
        aCoder.encode(headerColorIndex, forKey: "headerColorIndex")
        aCoder.encode(identifier, forKey: "identifier")
        if colorsArray == colorsArray { aCoder.encode(colorsArray, forKey: "colorArray")}
    }
    
    func encode(to encoder: Encoder) throws {
        
    }*/
    
    /*required convenience init?(coder aDecoder: NSCoder) {
        self.init(id:"--")
        self.name = aDecoder.decodeObject(forKey: "groupName") as! String
        self.headerColor = aDecoder.decodeObject(forKey: "headerColor") as! OPColor
        self.headerColorIndex = aDecoder.decodeInteger(forKey: "headerColorIndex")
        self.identifier = aDecoder.decodeObject(forKey: "identifier") as! String
        self.colorsArray = aDecoder.decodeObject(forKey: "colorArray") as! Array<OPColor>
    }*/
    
    init(id: String) {
        headerColor = OPColor.init()
        colorsArray = [OPColor]()
        headerColorIndex = 0
        self.name = "blank"
        identifier = id
        //super.init()
        self.findHeaderColor()
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
        if (colorsArray.count as Int?)! > 0 {
            let head = colorsArray[Int((colorsArray.count)/2)]
            headerColorIndex = Int((colorsArray.count)/2)
            setHeaderColor(header: head)
        }
    }
    
    func updateColorWeights(weights:[Int]) {
        for (i,color) in colorsArray.enumerated() {
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
    
    func setName(name:String){
        self.name = name
    }
    
    func setHeaderColor (header: OPColor) {
        headerColor = header;
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
