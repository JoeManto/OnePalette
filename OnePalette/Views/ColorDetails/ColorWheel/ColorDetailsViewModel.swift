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

class ColorDetailsViewModel: ObservableObject {
    
    var wheel: HSVColorWheel
    
    @Published private(set) var saturationComponent: CGFloat
    
    @Published var saturationSliderValue: CGFloat {
        willSet {
            if newValue != saturationComponent {
                saturationComponent = newValue
                saturationTextValue = String(format: "%.0f", newValue * 100)
            }
        }
    }

    @Published var saturationTextValue: String {
        willSet {
            if newValue != String(format: "%.0f", saturationComponent * 100) {
                if let percentage = Double(saturationTextValue), 0.0...1.0 ~= percentage {
                    saturationComponent = percentage
                    brightnessSliderValue = percentage
                }
            }
        }
    }
    
    @Published private(set) var brightnessComponent: CGFloat
    
    @Published var brightnessSliderValue: CGFloat {
        willSet {
            if newValue != brightnessComponent {
                brightnessComponent = newValue
                brightnessTextValue = String(format: "%.0f", newValue * 100)
            }
        }
    }

    @Published var brightnessTextValue: String {
        willSet {
            if newValue != String(format: "%.0f", brightnessComponent * 100) {
                if let percentage = Double(brightnessTextValue), 0.0...1.0 ~= percentage {
                    brightnessComponent = percentage
                    brightnessSliderValue = percentage
                }
            }
        }
    }
    
    var window: NSWindow {
        (NSApplication.shared.delegate as! AppDelegate).colorWindow
    }
    
    private var subs = Set<AnyCancellable>()
    
    init() {
        self.wheel = HSVColorWheel(config:
            HSVConfig(size: CGSize(width: 400, height: 400), saturation: 1.0, brightness: 1.0, alpha: 1.0)
        )
        self.wheel.create()
        
        self.brightnessComponent = 1.0
        self.saturationComponent = 1.0
        self.brightnessSliderValue = 1.0
        self.brightnessTextValue = "100"
        
        self.saturationTextValue = "100"
        self.saturationSliderValue = 1.0
    }
 
    func hsvWheelImage(size: CGSize) -> NSImage {
        self.wheel.create()
        return NSImage(size: size, data: self.wheel.data)
    }
}
