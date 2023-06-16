//
//  HSVColorWheel.swift
//  OnePalette
//
//  Created by Joe Manto on 6/1/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import AppKit

struct HSVConfig: Hashable {
    let size: CGSize
    var saturation: CGFloat
    var brightness: CGFloat
    var alpha: CGFloat
    
    static func == (lhs: HSVConfig, rhs: HSVConfig) -> Bool {
        return lhs.size == rhs.size
        && lhs.saturation == rhs.saturation
        && lhs.brightness == rhs.brightness
        && lhs.alpha == rhs.alpha
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(size.width)
        hasher.combine(size.height)
        hasher.combine(saturation)
        hasher.combine(brightness)
        hasher.combine(alpha)
    }
}

class HSVColorWheel {
    
    var cache = [HSVConfig: NSBitmapImageRep]()
    
    var config: HSVConfig
    var data: NSBitmapImageRep!
    
    init(config: HSVConfig) {
        self.config = config
        self.data = self.create()
    }
        
    @discardableResult func create() -> NSBitmapImageRep {
        if let map = cache[config] {
            self.data = map
            return map
        }
        
        let bitmap = BitmapUtil.createBitmap(size: config.size, background: .clear.usingColorSpace(.deviceRGB)!)!
        
        let padding = 10.0
        let radius: CGFloat = (config.size.width / 2.0) - padding
        
        // Normalize degrees to [0.0 - 1.0]
        let range1 = (min: 0.0, max: 359.0)
        let range2 = (min: 0.0, max: 1.0)
        let slope = (range2.max - range2.min) / (range1.max - range1.min)
        
        let width = Int(config.size.width)
        let height = Int(config.size.height)
        
        func fill(x: Int, y: Int) {
            let offsetX = x - (width / 2)
            let offsetY = y - (height / 2)
            
            let dist = abs(distance(x: offsetX , y: offsetY))
    
            guard dist <= radius else {
                return
            }
            
            let phi = Int(rad2deg(atan2f(Float(offsetY), Float(offsetX))) + 360.0) % 360
            let norm = (CGFloat(phi) - range1.min) * slope + range2.min
            
            bitmap.setColorNew(
                .init(hue: norm, saturation: config.saturation, brightness: config.brightness, alpha: config.alpha),
                atX: x, y: y
            )
        }
        
        for y in 0..<width {
            for x in 0..<height {
                fill(x: x, y: y)
            }
        }
        
        cache[config] = bitmap
        self.data = bitmap
        return bitmap
    }
    
    func update(saturation: CGFloat) {
        self.config.saturation = saturation
        
        if let map = cache[self.config] {
            self.data = map
        }
        
        self.data.set(saturation: saturation)
    }
    
    func update(brightness: CGFloat) {
        self.config.brightness = brightness
        
        if let map = cache[self.config] {
            self.data = map
        }
        
        self.data.set(brightness: brightness)
    }
    
    func update(alpha: CGFloat) {
        self.config.alpha = alpha
        
        if let map = cache[self.config] {
            self.data = map
        }
        
        self.data.set(alpha: alpha)
    }
    
    func getColor(in image: NSImage, imgX: Int, imgY: Int) -> NSColor? {
        let slopeX = self.data.pixelsWide / Int(image.size.width)
        let slopeY = self.data.pixelsHigh / Int(image.size.height)
        
        let x = imgX * slopeX
        let y = imgY * slopeY
        
        guard let color = self.data.colorAt(x: x, y: y) else {
            return nil
        }
        
        return color
    }
    
    /// Distance from center
    private func distance(x: Int, y: Int) -> CGFloat {
        let prod = pow(CGFloat(x), 2) + pow(CGFloat(y), 2)
        return sqrt(prod)
    }
    
    /// Converts radians to degrees
    private func rad2deg(_ number: Float) -> Float {
        return number * 180 / .pi
    }
}
