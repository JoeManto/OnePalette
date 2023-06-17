//
//  ColorComponentSliderView.swift
//  OnePalette
//
//  Created by Joe Manto on 6/8/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import AppKit
import SwiftUI

struct ColorComponentSlider: NSViewRepresentable {
    typealias NSViewType = ColorComponentSliderView
    
    let initalValue: CGFloat
    var percentage: Binding<CGFloat>
    
    init(initalValue: CGFloat = 1.0, percentage: Binding<CGFloat>) {
        self.initalValue = initalValue
        self.percentage = percentage
    }
    
    func makeNSView(context: Context) -> ColorComponentSliderView {
        ColorComponentSliderView(initalComponentValue: 1.0, percentage: percentage)
    }
    
    func updateNSView(_ nsView: ColorComponentSliderView, context: Context) {
        
    }
}

class ColorComponentSliderView: NSView {
    let inspector: ColorInspectorView
    var inspectorXConstraint: NSLayoutConstraint!
    let inspectorSize = CGSize(width: 22, height: 22)
    var didLayout: Bool = false
    
    lazy var slider: NSView = {
        let view = NSView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.wantsLayer = true
        view.layer?.borderColor = NSColor.darkGray.cgColor
        view.layer?.borderWidth = 2
        view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        view.layer?.cornerRadius = 8.0
        return view
    }()
    
    var componentPercentage: Binding<CGFloat>
    
    init(initalComponentValue: CGFloat = 1.0, percentage: Binding<CGFloat>) {
        self.componentPercentage = percentage
        
        self.inspector = ColorInspectorView()
        self.inspector.translatesAutoresizingMaskIntoConstraints = false
        
        super.init(frame: NSRect(x: 0, y: 0, width: 200, height: 44))
        
        self.inspectorXConstraint = inspector.leadingAnchor.constraint(equalTo: slider.leadingAnchor)
        
        self.inspector.onPan = { [weak self] gesture in
            self?.onInspectorPan(gesture: gesture)
        }
        
        let tapGesture = NSClickGestureRecognizer(target: self, action: #selector(self.onClick(_:)))
        self.addGestureRecognizer(tapGesture)
    
        self.addSubview(slider)
        self.addSubview(inspector)
        
        NSLayoutConstraint.activate([
            self.slider.topAnchor.constraint(equalTo: self.topAnchor),
            self.slider.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.slider.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -1),
            self.slider.heightAnchor.constraint(equalToConstant: inspectorSize.height),
            self.slider.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            self.inspector.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.inspector.heightAnchor.constraint(equalToConstant: inspectorSize.height),
            self.inspector.widthAnchor.constraint(equalToConstant: inspectorSize.width),
            self.inspectorXConstraint
        ])
    }
    
    override func layout() {
        super.layout()
        
        if !self.didLayout {
            self.inspectorXConstraint.constant = self.slider.frame.width - self.inspectorSize.width
            self.didLayout.toggle()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onClick(_ gesture: NSGestureRecognizer) {
        self.onInspectorPan(gesture: gesture)
    }
    
    func onInspectorPan(gesture: NSGestureRecognizer) {
        let location = gesture.location(in: self.slider)
        let x = location.x - (self.inspectorSize.width / 2)
        
        let range = (min: 0.0, max: self.slider.frame.width - self.inspectorSize.width)
        
        guard x >= range.min, x <= range.max else {
            return
        }

        self.componentPercentage.wrappedValue = min(1.0, x * (1 / range.max))
        self.inspectorXConstraint.constant = x
    }
}
