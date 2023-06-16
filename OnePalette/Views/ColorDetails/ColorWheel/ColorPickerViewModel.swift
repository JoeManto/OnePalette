//
//  ColorPickerViewModel.swift
//  OnePalette
//
//  Created by Joe Manto on 6/8/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import AppKit

class ColorDetailsViewModel {
    
    var wheel: HSVColorWheel
    
    init() {
        self.wheel = HSVColorWheel(config:
            HSVConfig(size: CGSize(width: 400, height: 400), saturation: 1.0, brightness: 1.0, alpha: 1.0)
        )
        self.wheel.create()
    }
 
    func hsvWheelImage(size: CGSize) -> NSImage {
        self.wheel.create()
        return NSImage(size: size, data: self.wheel.data)
    }
}
