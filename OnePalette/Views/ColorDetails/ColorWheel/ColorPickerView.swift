//
//  ColorPickerView.swift
//  OnePalette
//
//  Created by Joe Manto on 5/30/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import AppKit
import Combine
import SwiftUI

class ColorPickerView: NSView {
    
    private(set) var colorView = NSImageView()
    
    private(set) lazy var inspector: ColorInspectorView = {
        ColorInspectorView(onPan: { [weak self] gesture in
            self?.onInspectorChange(gesture)
        })
    }()
    
    let vm: ColorDetailsViewModel
    
    var xConstraint: NSLayoutConstraint!
    var yConstraint: NSLayoutConstraint!
    
    let wheelSize = CGSize(width: 200, height: 200)
    
    private var subs = Set<AnyCancellable>()
    
    init(vm: ColorDetailsViewModel) {
        self.vm = vm
        super.init(frame: .zero)
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        
        self.colorView.image = vm.hsvWheelImage(size: self.wheelSize)
        self.colorView.wantsLayer = true
        self.colorView.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        self.colorView.translatesAutoresizingMaskIntoConstraints = false
        
        self.inspector.translatesAutoresizingMaskIntoConstraints = false
      
        xConstraint = inspector.centerXAnchor.constraint(equalTo: self.colorView.leadingAnchor, constant: self.wheelSize.width / 2)
        yConstraint = inspector.centerYAnchor.constraint(equalTo: self.colorView.topAnchor, constant: self.wheelSize.height / 2)
        
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(self.onInspectorChange(_:)))
        clickGesture.numberOfClicksRequired = 1
        self.colorView.addGestureRecognizer(clickGesture)
        
        self.addSubview(self.colorView)
        self.addSubview(self.inspector)
        
        self.setConstraints()
        
        self.vm.$brightnessComponent
            .debounce(for: .seconds(0.1), scheduler: RunLoop.main)
            .sink { [unowned self] percentage in
                self.vm.wheel.update(brightness: percentage)
                self.updateWheelImage()
            }
            .store(in: &subs)
        
        self.vm.$saturationComponent
            .debounce(for: .seconds(0.1), scheduler: RunLoop.main)
            .sink { [unowned self] percentage in
                self.vm.wheel.update(saturation: percentage)
                self.updateWheelImage()
            }
            .store(in: &subs)
    }

    func setConstraints() {
        // Color View
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: self.topAnchor),
            colorView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
  
            colorView.widthAnchor.constraint(equalToConstant: 200),
            colorView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        // Inspector
        NSLayoutConstraint.activate([
            xConstraint,
            yConstraint,
            inspector.widthAnchor.constraint(equalToConstant: 24),
            inspector.heightAnchor.constraint(equalToConstant: 24),
        ])
    }
    
    func updateWheelImage() {
        self.colorView.image = self.vm.hsvWheelImage(size: self.wheelSize)
        self.setNeedsDisplay(self.frame)
        self.updateInspectorBackground()
    }
    
    @objc func onInspectorChange(_ gesture: NSGestureRecognizer?) {
        let location = gesture?.location(in: self.colorView) ?? CGPoint(x: xConstraint.constant, y: yConstraint.constant)

        let x = location.x
        let y = wheelSize.height - location.y
        
        xConstraint.constant = x
        yConstraint.constant = y
        
        updateInspectorBackground()
    }
    
    func updateInspectorBackground() {
        guard let img = colorView.image else {
            return
        }
        
        if let color = vm.wheel.getColor(in: img, imgX: Int(xConstraint.constant), imgY: Int(yConstraint.constant)) {
            self.inspector.layer?.backgroundColor = color.cgColor
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
