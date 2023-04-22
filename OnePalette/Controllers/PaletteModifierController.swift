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
    
    private var subs = Set<AnyCancellable>()
        
    lazy var contentViewModel: PaletteEditingContentViewModel = {
        PaletteEditingContentViewModel(palette: PaletteService.shared.palettes.first)
    }()
    
    lazy var navViewModel: NavigationViewModel = {
        NavigationViewModel(items: PaletteService.shared.palettes.map {
            NavigationItem(displayName: $0.paletteName, value: $0)
        })
    }()

    lazy var navigationController = {
        let vc = NavigationViewController()
        let navView = NavigationView(vm: self.navViewModel)
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
    
    lazy var contentController = {
        let vc = NavigationViewController()
        
        let contentView = PaletteEditingContentView(vm: self.contentViewModel)
        let view = NSHostingView(rootView: contentView)
        
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
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        contentViewModel.paletteNameChangePublisher.sink { [unowned self] pal in
            self.navViewModel.activeItem = NavigationItem(displayName: pal.paletteName, value: pal)
        }
        .store(in: &self.subs)
        
        contentViewModel.paletteDeletePublisher.sink { [unowned self] removedPalette in
            guard let pal = PaletteService.shared.palettes.first else {
                return
            }
            
            self.contentViewModel.updatePalette(palette: pal)
            self.navViewModel.activeItem = NavigationItem(displayName: pal.paletteName, value: pal)
        }
        .store(in: &self.subs)
        
        navViewModel.onNewItem = { [weak navViewModel] in
            let newPalette = PaletteService.shared.installEmptyPalette()
            
            navViewModel?.items = PaletteService.shared.palettes.map {
                NavigationItem(displayName: $0.paletteName, value: $0)
            }
            
            navViewModel?.activeItem = NavigationItem(displayName: newPalette.paletteName, value: newPalette)
        }
        
        navViewModel.navigationPublisher.sink { [unowned self] item in
            guard let palette = PaletteService.shared.palettes.first(where: { $0.paletteName == item.displayName }) else {
                return
            }
            
            self.contentViewModel.updatePalette(palette: palette)
        }
        .store(in: &self.subs)
    }
    
    override func viewWillDisappear() {
        let curGroup = self.contentViewModel.selectedColorGroup
        self.contentViewModel.palette.updateColorGroup(group: curGroup, save: true)
        super.viewWillDisappear()
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
        itemA.minimumThickness = 150
        self.addSplitViewItem(itemA)

        let itemB = NSSplitViewItem(contentListWithViewController: self.contentController)
        itemB.minimumThickness = 100
        addSplitViewItem(itemB)
    }
}
