//
//  QuotesViewController.swift
//  OnePalette
//
//  Created by Joe Manto on 3/1/18.
//  Copyright © 2018 Joe Manto. All rights reserved.
//

import Cocoa
import CoreData
import SwiftUI

class ColorViewerController: NSHostingController<PaletteView> {
    
    var curPal: Palette
    var paletteViewModel: PaletteViewModel
    
    init(curPal: Palette) {
        self.curPal = curPal
        self.paletteViewModel = PaletteViewModel(palette: curPal)
        
        let palView = PaletteView(vm: self.paletteViewModel)
        
        super.init(rootView: palView)
        
        self.paletteViewModel.onNext = { [weak self] pal in
            
        }
        
        self.paletteViewModel.onPrev = { [weak self] pal in
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        self.addBackgroundBlur()
        self.paletteViewModel.updateViewModels()
        
        super.viewWillAppear()
    }
    
    @MainActor required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NSViewController {
    
    func addBackgroundBlur() {
        self.view.window?.isOpaque = false
        self.view.window?.alphaValue = 0.98
        
        let blurView = NSVisualEffectView(frame: .zero)
        blurView.blendingMode = .behindWindow
        blurView.material = .popover
        blurView.state = .active
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(blurView)
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo:  self.view.topAnchor),
            blurView.leadingAnchor.constraint(equalTo:  self.view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo:  self.view.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo:  self.view.bottomAnchor)
        ])
    }
}
