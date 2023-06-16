//
//  ColorComponentSliderView.swift
//  OnePalette
//
//  Created by Joe Manto on 6/8/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import AppKit

class ColorComponentSliderView: NSView, NSTextFieldDelegate, NSControlTextEditingDelegate {
    
    let inspector: ColorInspectorView
    var inspectorXConstraint: NSLayoutConstraint!
    let inspectorSize = CGSize(width: 22, height: 22)
    var didLayout: Bool = false
    
    let title: String
    
    lazy var titleView: NSTextField = {
        let field = NSTextField()
        field.target = self
        field.textColor = .lightGray
        field.font = NSFont.boldSystemFont(ofSize: 12)
        field.isBordered = false
        field.isBezeled = false
        field.isEditable = false
        field.refusesFirstResponder = true
        field.backgroundColor = .clear
        field.translatesAutoresizingMaskIntoConstraints = false
        field.stringValue = self.title
        return field
    }()
    
    lazy var percentageField: NSTextField = {
        let field = NSTextField()
        //field.label = "%"
        field.focusRingType = .none
        field.isBordered = false
        field.isEditable = true
        field.isSelectable = true
        field.drawsBackground = false
        field.translatesAutoresizingMaskIntoConstraints = false
        field.stringValue = String(format: "%f.1", self.componentPercentage * 100)
        return field
    }()
    
    lazy var slider: NSView = {
        let view = NSView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.wantsLayer = true
        view.layer?.borderColor = NSColor.gray.cgColor
        view.layer?.borderWidth = 2
        view.layer?.backgroundColor = NSColor.lightGray.cgColor
        view.layer?.cornerRadius = 8.0
        return view
    }()
    
    @Published var componentPercentage: CGFloat
    
    init(title: String, initalComponentValue: CGFloat = 1.0) {
        self.title = title
        self.componentPercentage = initalComponentValue
        self.inspector = ColorInspectorView()
        self.inspector.translatesAutoresizingMaskIntoConstraints = false
        
        super.init(frame: NSRect(x: 0, y: 0, width: 200, height: 44))
        
        self.inspectorXConstraint = inspector.leadingAnchor.constraint(equalTo: slider.leadingAnchor)
        
        self.inspector.onPan = { [weak self] gesture in
            self?.onInspectorPan(gesture: gesture)
        }
        
        let tapGesture = NSClickGestureRecognizer(target: self, action: #selector(self.onClick(_:)))
        self.addGestureRecognizer(tapGesture)
        
        let perTapGesture = NSClickGestureRecognizer(target: self, action: #selector(self.onPercentageFieldTap(_:)))
        self.addGestureRecognizer(perTapGesture)
        percentageField.addGestureRecognizer(perTapGesture)
    
        self.addSubview(titleView)
        self.addSubview(percentageField)
        self.addSubview(slider)
        self.addSubview(inspector)
        
        NSLayoutConstraint.activate([
            self.titleView.topAnchor.constraint(equalTo: self.topAnchor),
            self.titleView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.titleView.trailingAnchor.constraint(equalTo: self.trailingAnchor),

            self.percentageField.centerYAnchor.constraint(equalTo: self.slider.centerYAnchor),
            self.percentageField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            self.percentageField.widthAnchor.constraint(equalToConstant: 55),
            
            self.slider.topAnchor.constraint(equalTo: self.titleView.bottomAnchor, constant: 2),
            self.slider.leadingAnchor.constraint(equalTo: self.percentageField.trailingAnchor, constant: 5),
            self.slider.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -1),
            self.slider.heightAnchor.constraint(equalToConstant: inspectorSize.height),
            self.slider.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            self.inspector.topAnchor.constraint(equalTo: self.titleView.bottomAnchor, constant: 2),
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
        self.percentageField.abortEditing()
    }
    
    @objc func onPercentageFieldTap(_ gesture: NSGestureRecognizer) {
        let editor = percentageField.currentEditor()

        
        //percentageField.currentEditor()?.
    }
    
    func onInspectorPan(gesture: NSGestureRecognizer) {
        let location = gesture.location(in: self.slider)
        let x = location.x - (self.inspectorSize.width / 2)
        
        let range = (min: 0.0, max: self.slider.frame.width - self.inspectorSize.width)
        
        guard x >= range.min, x <= range.max + 1 else {
            return
        }

        self.componentPercentage = min(1.0, x * (1 / range.max))
        self.percentageField.stringValue = String(format: "%f.1", self.componentPercentage * 100)
        self.inspectorXConstraint.constant = x
    }
    
    // MARK: NSTextFieldDelegate
    
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        DispatchQueue.main.async {
            self.percentageField.window!.makeFirstResponder(nil)
        }
        return true
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        self.percentageField.resignFirstResponder()
    }
}
