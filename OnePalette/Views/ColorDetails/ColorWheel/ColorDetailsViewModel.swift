//
//  ColorPickerViewModel.swift
//  OnePalette
//
//  Created by Joe Manto on 6/8/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import AppKit
import SwiftUI
import Combine

enum ColorUpdateSource {
    case inspectorChange, hexChange, brightnessChange, saturationChange, silent
}

class ColorDetailsViewModel: ObservableObject {
    
    var wheel: HSVColorWheel
    
    @Published private var color: NSColor {
        didSet {
            let cur = color.toHexString.normalisedHexString()
            let new = hexStringTextValue.normalisedHexString()
            
            if cur != new {
                print("Updating color new <\(new)> cur <\(cur)>")
                
                hexStringTextValue = cur
            }
        }
    }
    
    @Published var hexStringTextValue: String
    
    @Published private(set) var saturationComponent: CGFloat
    
    @Published var saturationSliderValue: CGFloat {
        willSet {
            if newValue != saturationComponent {
                self.updateSaturation(component: newValue)
            }
        }
    }

    @Published var saturationTextValue: String {
        willSet {
            if newValue != String(format: "%.0f", saturationComponent * 100) {
                if let percentage = Double(saturationTextValue), 0.0...100.0 ~= percentage {
                    let percent = percentage / 100
                    saturationSliderValue = percent
                }
            }
        }
    }
    
    @Published private(set) var brightnessComponent: CGFloat
    
    @Published var brightnessSliderValue: CGFloat {
        willSet {
            if newValue != brightnessComponent {
                self.udpateBrightness(component: newValue)
            }
        }
    }

    @Published var brightnessTextValue: String {
        willSet {
            if newValue != String(format: "%.0f", brightnessComponent * 100) {
                if let percentage = Double(saturationTextValue), 0.0...100.0 ~= percentage {
                    let percent = percentage / 100
                    brightnessSliderValue = percent
                }
            }
        }
    }
    
    let colorUpdatePublisher = PassthroughSubject<(NSColor, ColorUpdateSource), Never>()
    
    var window: NSWindow {
        (NSApplication.shared.delegate as! AppDelegate).colorWindow
    }
    
    private var subs = Set<AnyCancellable>()
    
    init() {
        self.wheel = HSVColorWheel(config:
            HSVConfig(size: CGSize(width: 400, height: 400), saturation: 1.0, brightness: 1.0, alpha: 1.0)
        )
        
        let defaultColor = NSColor(hue: 1.0, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        self.color = defaultColor
        self.brightnessComponent = 1.0
        self.saturationComponent = 1.0
        
        self.brightnessSliderValue = 1.0
        self.brightnessTextValue = "100"
        
        self.saturationTextValue = "100"
        self.saturationSliderValue = 1.0
        
        self.hexStringTextValue = defaultColor.toHexString.normalisedHexString()
    }
 
    func hsvWheelImage(size: CGSize) -> NSImage {
        self.wheel.create()
        return NSImage(size: size, data: self.wheel.data)
    }
    
    func onHexTextEditEnd() {
        DispatchQueue.main.async {
            self.hexStringTextValue = self.hexStringTextValue.normalisedHexString()
            self.onColorChange(to: NSColor.hex(self.hexStringTextValue, alpha: 1.0), from: .hexChange)
        }
    }
    
    func updateSaturation(component: CGFloat) {
        saturationComponent = component
        saturationTextValue = String(format: "%.0f", component * 100)
    }
    
    func udpateBrightness(component: CGFloat) {
        brightnessComponent = component
        brightnessTextValue = String(format: "%.0f", component * 100)
    }
    
    func onColorChange(to color: NSColor, from source: ColorUpdateSource) {
        self.color = color
        
        guard source != .silent else {
            return
        }
        
        colorUpdatePublisher.send((color, source))
    }
}
