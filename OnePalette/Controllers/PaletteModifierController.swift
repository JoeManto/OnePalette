//
//  PaletteModifierController.swift
//  OnePalette
//
//  Created by Joe Manto on 12/11/22.
//  Copyright © 2022 Joe Manto. All rights reserved.
//

import Foundation
import AppKit
import SwiftUI
import Combine

class NavigationViewController: NSViewController {
    init() {
       super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
       view = NSView()
       view.wantsLayer = true
    }
}

class PaletteModifierViewController: NSSplitViewController {
    
    private let splitViewResorationIdentifier = "com.company.restorationId:mainSplitViewController"
    
    var subs = Set<AnyCancellable>()
        
    lazy var contentViewModel: PaletteEditingContentViewModel = {
        PaletteEditingContentViewModel(palette: PaletteService.shared.palettes.first)
    }()

    lazy var navigationController = {
        let vc = NavigationViewController()
        let navView = PaletteNavigationView(vm: PaletteNavigationViewModel(palettes: PaletteService.shared.palettes))
        let view = NSHostingView(rootView: navView)
        view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            view.topAnchor.constraint(equalTo: vc.view.topAnchor),
            view.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor)
        ])
        
        navView.vm.navigationPublisher.sink { [weak self] selectedPalette in
            guard let palette = selectedPalette as? Palette else {
                return
            }
            print(palette.paletteName)
            
            self?.contentViewModel.palette = palette
        }
        .store(in: &self.subs)
        
        return vc
    }()
    
    lazy var contentController = {
        let vc = NavigationViewController()
        
        let navView = PaletteEditingContentView(vm: self.contentViewModel)
        let view = NSHostingView(rootView: navView)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            view.topAnchor.constraint(equalTo: vc.view.topAnchor),
            view.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor)
        ])
        
        return vc
    }()

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
       super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupUI()
        setupLayout()
    }

    required init?(coder: NSCoder) {
       super.init(coder: coder)
    }
    
    private func setupUI() {
       view.wantsLayer = true

       splitView.dividerStyle = .paneSplitter
       splitView.autosaveName = NSSplitView.AutosaveName(rawValue: splitViewResorationIdentifier)
       splitView.identifier = NSUserInterfaceItemIdentifier(rawValue: splitViewResorationIdentifier)
    }

    private func setupLayout() {
        minimumThicknessForInlineSidebars = 180

        let itemA = NSSplitViewItem(sidebarWithViewController: self.navigationController)
        itemA.minimumThickness = 80
        self.addSplitViewItem(itemA)

        let itemB = NSSplitViewItem(contentListWithViewController: self.contentController)
        itemB.minimumThickness = 100
        addSplitViewItem(itemB)
    }
}