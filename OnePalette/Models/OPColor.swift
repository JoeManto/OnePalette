//
//  OPColor.swift
//  OnePalette
//
//  Created by Joe Manto on 3/6/18.
//  Copyright © 2018 Joe Manto. All rights reserved.
//

import Cocoa
import AppSDK

class OPColor: Identifiable, Codable, NSCopying {

    private(set) var weight: Int
    private(set) var hexValue: String
    private(set) var lum: Float
    
    private(set) var saveableColor: CodeableColor
    
    var color: NSColor {
        get {
            self.saveableColor.nsColor
        }
        set {
            self.saveableColor = CodeableColor(from: newValue)
            self.lum = Float(calcLum())
            self.hexValue = newValue.toHexString
        }
    }
    
    init() {
        self.weight = 0
        self.lum = 0;
        self.hexValue = "#"
        self.saveableColor = CodeableColor(from: .cyan)
    }
    
    convenience init(hexString: String, alpha: CGFloat = 1.0, weight: Int) {
        self.init()
        
        self.hexValue = hexString
        let colorValue = NSColor.hex(hexString, alpha: alpha)
        self.saveableColor = CodeableColor(from: colorValue)
        self.weight = weight
        
        self.lum = Float(calcLum())
    }
    
    convenience init(nsColor: NSColor, weight: Int = 0) {
        self.init()
        
        self.hexValue = nsColor.toHexString
        self.color = nsColor
        self.weight = weight
        self.lum = Float(calcLum())
    }
    
    private func calcLum() -> CGFloat {
        let color = self.color
        return (0.299 * color.redComponent + 0.587 * color.greenComponent + 0.114 * color.blueComponent)
    }
    
    func getWeight() -> Int {
        return self.weight
    }
    
    func setWeight(weight: Int){
        self.weight = weight
    }
    
    func getHexString() -> String {
        return hexValue
    }

    required init?(pasteboardPropertyList propertyList: Any, ofType type: NSPasteboard.PasteboardType) {
        fatalError("init(pasteboardPropertyList:ofType:) has not been implemented")
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = OPColor(nsColor: self.color, weight: self.weight)
        return copy
    }
    
    func shallowCopy() -> OPColor {
        return self.copy() as! OPColor
    }
}

// MARK: OPColor Factory

extension OPColor {
    
    static func empty() -> OPColor {
        return OPColor(hexString: "000000", alpha: 0.2, weight: 0)
    }
    
    static func randomGray(weight: Int) -> OPColor {
        let val = CGFloat.random(in: 0.20...0.80)
        var comps: [CGFloat] = [val, val, val, 1.0]
        
        // TODO: will need to take in color space param in the future
        let color = NSColor(colorSpace: .sRGB, components: &comps, count: 4)
        
        return OPColor(nsColor: color, weight: weight)
    }
}

extension [OPColor] {
    func sortedByBrightness() -> [OPColor] {
        self.sorted(by: { a, z in
            a.lum > z.lum
        })
    }
}
