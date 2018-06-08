//
//  OPColorGroup.swift
//  OnePalette
//
//  Created by Joe Manto on 3/6/18.
//  Copyright © 2018 Joe Manto. All rights reserved.
//

import Cocoa
import CoreData

class OPColorGroup : NSObject,NSCoding {

    private var headerColor:OPColor
    var headerColorIndex:Int
    private var name:String
    private var identifier:String
    var colorsArray:Array<OPColor>
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "groupName")
        aCoder.encode(headerColor, forKey: "headerColor")
        aCoder.encode(headerColor, forKey: "headerColorIndex")
        aCoder.encode(identifier, forKey: "identifier")
        if colorsArray == colorsArray { aCoder.encode(colorsArray, forKey: "colorArray")}
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(name: "")
        self.name = aDecoder.decodeObject(forKey: "groupName") as! String
        self.headerColor = aDecoder.decodeObject(forKey: "headerColor") as! OPColor
        self.headerColorIndex = aDecoder.decodeInteger(forKey: "headerColorIndex")
        self.identifier = aDecoder.decodeObject(forKey: "identifier") as! String
        self.colorsArray = aDecoder.decodeObject(forKey: "colorArray") as! Array<OPColor>
    }
    
    init(name:String) {
        headerColor = OPColor.init()
        colorsArray = Array<OPColor>()
        headerColorIndex = 0
        self.name = name
        identifier = ""
        super.init()
        self.findHeaderColor()
        identifier = self.genIdOfLength(len: 6) as String
    }
    
    func addColor(color:OPColor) {
        colorsArray.append(color)
    }
    
    func getColorArray() -> Array<OPColor> {
        return self.colorsArray
    }
    
    func getName() -> String {
        return name.firstUppercased
    }
    func setHeaderColor (header:OPColor) {
        headerColor = header;
    }
    
    func getHeaderColor() -> OPColor {
        return headerColor
    }
    
    func findHeaderColor() {
        if (colorsArray.count as Int?)! > 0 {
            let head = colorsArray[Int((colorsArray.count)/2)]
            headerColorIndex = Int((colorsArray.count)/2)
            setHeaderColor(header: head)
        }
    }
    func updateColorWeights(weights:[Int]) {
        for (i,color) in colorsArray.enumerated(){
            color.setWeight(weight: weights[i])
        }
    }
    
    func description()->String {
        return "ColorGroup:Name "+name
    }
    
    func genIdOfLength(len: Int) -> NSString {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        let randomString : NSMutableString = NSMutableString(capacity: len)
        
        for _ in 1...len{
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.character(at: Int(rand)))
        }
        
        return randomString
    }
 
}
extension String {
    var firstUppercased: String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }
}
