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
    var curColorGroup: OPColorGroup
    var paletteViewModel: PaletteViewModel
    
    init(curPal: Palette) {
        self.curPal = curPal
        self.curColorGroup = curPal.paletteData?.first?.value ?? OPColorGroup(id: "empty")
        
        self.paletteViewModel = PaletteViewModel(palette: curPal,
        onNext: { pal in
    
        }, onPrev: { pal in

        })
        
        super.init(rootView: PaletteView(vm: self.paletteViewModel))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        // Adds transparency to the app
        view.window?.isOpaque = false
        view.window?.alphaValue = 0.98
        
        let blurView = NSVisualEffectView(frame: .zero)
        blurView.blendingMode = .behindWindow
        blurView.material = .popover
        blurView.state = .active
        blurView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(blurView)
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: self.view.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
       
    }
    
    @MainActor required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
