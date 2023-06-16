//
//  BitmapUtil.swift
//  OnePalette
//
//  Created by Joe Manto on 6/1/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import AppKit

struct BitmapUtil {
    
    static func createBitmap(size: CGSize, background: NSColor) -> NSBitmapImageRep? {
        guard let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(size.width),
            pixelsHigh: Int(size.height),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: NSColorSpaceName.calibratedRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        ) else {
            return nil
        }
        
        bitmap.fill(with: background)
        
        return bitmap
    }
    
    /// Distance from center
    static func distance(x: Int, y: Int) -> CGFloat {
        let prod = pow(CGFloat(x), 2) + pow(CGFloat(y), 2)
        return sqrt(prod)
    }
}

extension NSBitmapImageRep {
    func setColorNew(_ color: NSColor, atX x: Int, y: Int) {
        guard let data = bitmapData else { return }
        
        let ptr = data + bytesPerRow * y + samplesPerPixel * x
        
        ptr[0] = UInt8(color.redComponent * 255.1)
        ptr[1] = UInt8(color.greenComponent * 255.1)
        ptr[2] = UInt8(color.blueComponent * 255.1)
        
        if samplesPerPixel > 3 {
            ptr[3] = UInt8(color.alphaComponent * 255.1)
        }
    }
    
    func fill(with color: NSColor) {
        for y in 0..<pixelsHigh {
            for x in 0..<pixelsWide {
                self.setColorNew(color, atX: x, y: y)
            }
        }
    }
    
    func set(saturation: CGFloat) {
        for y in 0..<pixelsHigh {
            for x in 0..<pixelsWide {
                let color = self.colorAt(x: x, y: y) ?? .clear.usingColorSpace(.deviceRGB)!
                
                guard color.alphaComponent > 0 else {
                    continue
                }
                
                self.setColorNew(.init(
                    hue: color.hueComponent,
                    saturation: saturation,
                    brightness: color.brightnessComponent,
                    alpha: color.alphaComponent
                ), atX: x, y: y)
            }
        }
    }
    
    func set(brightness: CGFloat) {
        for y in 0..<pixelsHigh {
            for x in 0..<pixelsWide {
                let color = self.colorAt(x: x, y: y) ?? .clear.usingColorSpace(.deviceRGB)!
                
                guard color.alphaComponent > 0 else {
                    continue
                }
                
                self.setColorNew(.init(
                    hue: color.hueComponent,
                    saturation: color.saturationComponent,
                    brightness: brightness,
                    alpha: color.alphaComponent
                ), atX: x, y: y)
            }
        }
    }
    
    func set(alpha: CGFloat) {
        for y in 0..<pixelsHigh {
            for x in 0..<pixelsWide {
                let color = self.colorAt(x: x, y: y) ?? .clear.usingColorSpace(.deviceRGB)!
                
                guard color.alphaComponent > 0 else {
                    continue
                }
                
                self.setColorNew(.init(
                    hue: color.hueComponent,
                    saturation: color.saturationComponent,
                    brightness: color.brightnessComponent,
                    alpha: alpha
                ), atX: x, y: y)
            }
        }
    }
}

extension NSImage {
    convenience init(size: CGSize, data: NSBitmapImageRep) {
        self.init(size: size)
        self.addRepresentation(data)
    }
}

