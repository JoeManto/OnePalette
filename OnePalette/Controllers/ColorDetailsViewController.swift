//
//  ColorDetailsViewController.swift
//  OnePalette
//
//  Created by Joe Manto on 6/15/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import AppKit
import SwiftUI

class ColorDetailsViewController: NSViewController {
    
    let vm: ColorDetailsViewModel
    
    init(vm: ColorDetailsViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = NSView()
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
    }
    
    override func viewDidLoad() {
        let picker = ColorPickerView(vm: self.vm)
        picker.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(picker)
        
        let detailsView = NSHostingView(rootView: ColorDetailsView(vm: self.vm))
        detailsView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(detailsView)
        
        NSLayoutConstraint.activate([
            picker.topAnchor.constraint(equalTo: self.view.topAnchor),
            picker.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            picker.heightAnchor.constraint(equalToConstant: 200),
            
            detailsView.topAnchor.constraint(equalTo: picker.bottomAnchor),
            detailsView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            detailsView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            detailsView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        super.viewDidLoad()
    }
}
