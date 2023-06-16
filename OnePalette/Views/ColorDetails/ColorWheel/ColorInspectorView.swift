//
//  ColorInspectorView.swift
//  OnePalette
//
//  Created by Joe Manto on 6/5/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import AppKit

class ColorInspectorView: NSView {
    
    var onPan: ((NSGestureRecognizer) -> Void)?
    
    init(onPan: ((NSGestureRecognizer) -> Void)? = nil) {
        self.onPan = onPan
        super.init(frame: NSRect(x: 0, y: 0, width: 44, height: 44))
    
        self.wantsLayer = true
        self.layer?.borderColor = NSColor.gray.cgColor
        self.layer?.borderWidth = 2
        self.layer?.backgroundColor = NSColor.white.cgColor
        
        let pan = NSPanGestureRecognizer(target: self, action: #selector(self.onPanGesture(_:)))
        self.addGestureRecognizer(pan)
    }
    
    override func layout() {
        super.layout()
        layer?.cornerRadius = self.frame.size.width / 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onPanGesture(_ sender: NSPanGestureRecognizer) {
        self.onPan?(sender)
    }
}
