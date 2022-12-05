//
//  OPColor.swift
//  OnePalette
//
//  Created by Joe Manto on 3/6/18.
//  Copyright © 2018 Joe Manto. All rights reserved.
//

import Cocoa

class OPColor: Identifiable, Codable {
    
    private var weight: Int
    var saveableColor: CodeableColor
    private var hexValue: String
    private var componentRed: Float
    private var componentGreen: Float
    private var componentBlue: Float
    private var componentAlpha: Float
    private var lum: Float
    
    var color: NSColor {
        saveableColor.nsColor
    }
    
    /*func encode(with aCoder: NSCoder) {
        aCoder.encode(self.weight, forKey: "weight")
        aCoder.encode(self.color, forKey: "color")
        aCoder.encode(self.hexValue, forKey: "hex")
        aCoder.encode(self.componentRed, forKey: "componentRed")
        aCoder.encode(self.componentGreen, forKey: "componentGreen")
        aCoder.encode(self.componentBlue, forKey: "componentBlue")
        aCoder.encode(self.componentAlpha, forKey: "componentAlpha")
        aCoder.encode(self.lum, forKey: "lum")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        
        self.weight = aDecoder.decodeInteger(forKey: "weight")
        self.color = aDecoder.decodeObject(forKey: "color") as! NSColor
        self.hexValue = aDecoder.decodeObject(forKey: "hex") as! String
        self.componentRed = Float(aDecoder.decodeFloat(forKey: "componentRed"))
        self.componentGreen = Float(aDecoder.decodeFloat(forKey: "componentGreen"))
        self.componentBlue = Float(aDecoder.decodeFloat(forKey: "componentBlue"))
        self.componentAlpha = Float(aDecoder.decodeFloat(forKey: "componentAlpha"))
        self.lum = Float(aDecoder.decodeFloat(forKey: "lum"))
    }*/
    
    init() {
        self.weight = 0
        self.lum = 0;
        self.componentRed = -1
        self.componentGreen = -1
        self.componentBlue = -1
        self.componentAlpha = -1
        self.hexValue = "#"
        self.saveableColor = CodeableColor(from: .cyan)
    }
    
    convenience init(hexString: String, alpha: CGFloat = 1.0,weight:Int) {
        self.init()
        
        self.hexValue = hexString
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        let colorValue = NSColor.init(red: red, green: green, blue: blue, alpha: alpha)
        self.saveableColor = CodeableColor(from: colorValue)
        self.weight = weight
        componentRed = Float(colorValue.redComponent*255)
        componentGreen = Float(colorValue.greenComponent*255)
        componentAlpha = Float(colorValue.blueComponent*255)
        self.lum = Float(calcLum())
    }
    
    func calcLum() -> CGFloat {
        let color = self.color
        return (0.299 * color.redComponent + 0.587 * color.greenComponent + 0.114 * color.blueComponent)
    }
    
    func getWeight() -> Int {
        return self.weight
    }
    
    func setWeight(weight:Int){
        self.weight = weight
    }
    
    func getHexString() -> String {
        return hexValue
    }
    
    func getColorComponents() -> (Float?, Float?, Float?) { //add alpha
        return (self.componentRed, self.componentGreen, self.componentBlue)
    }
    
    required init?(pasteboardPropertyList propertyList: Any, ofType type: NSPasteboard.PasteboardType) {
        fatalError("init(pasteboardPropertyList:ofType:) has not been implemented")
    }
}

extension NSColor{
    
    var toHexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return String(
            format: "%02X%02X%02X",
            Int(r * 0xff),
            Int(g * 0xff),
            Int(b * 0xff)
        )
    }
}
