//
//  CopyFormatEditorController.swift
//  OnePalette
//
//  Created by Joe Manto on 4/20/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import AppKit
import SwiftUI
import Combine

class CopyFormatEditorViewController: NSSplitViewController {
    
    private let splitViewResorationIdentifier = "com.company.restorationId:mainSplitViewController"
    
    private var subs = Set<AnyCancellable>()
        
    lazy var contentViewModel: CopyFormatEditorViewModel = {
        if CopyFormatService.shared.formats.isEmpty {
            CopyFormatService.shared.add(format: .default())
        }
        
        return CopyFormatEditorViewModel(currentformatId: CopyFormatService.shared.formats.first!.id)
    }()
    
    lazy var navViewModel: NavigationViewModel = {
        NavigationViewModel(items: CopyFormatService.shared.formats.map {
            NavigationItem(displayName: $0.name, value: $0)
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
        
        let contentView = CopyFormatEditorView(vm: self.contentViewModel)
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
        
        navViewModel.onNewItem = { [weak navViewModel] in
            let format = CopyFormat.nameUnique()
            CopyFormatService.shared.add(format: format)
            
            navViewModel?.items = CopyFormatService.shared.formats.map {
                NavigationItem(displayName: $0.name, value: $0)
            }
        }
        
        navViewModel.navigationPublisher.sink { [unowned self] item in
            guard let format = item.value as? CopyFormat else {
                return
            }
            contentViewModel.update(formatId: format.id)
        }
        .store(in: &self.subs)
        
        contentViewModel.formatDeletePublisher.sink { [unowned self] _ in
            navViewModel.items = CopyFormatService.shared.formats.map {
                NavigationItem(displayName: $0.name, value: $0)
            }
            
            if let format = CopyFormatService.shared.formats.first {
                contentViewModel.update(formatId: format.id)
                navViewModel.activeItem = self.navViewModel.items.first ?? NavigationItem(displayName: format.name, value: format)
            }
        }
        .store(in: &self.subs)
    }
    
    override func viewWillDisappear() {
        contentViewModel.saveFormat()
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
