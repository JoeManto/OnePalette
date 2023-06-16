//
//  NavigationViewViewModel.swift
//  OnePalette
//
//  Created by Joe Manto on 4/20/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import Combine

struct NavigationItem: Identifiable, Equatable {
    let id = UUID()
    let displayName: String
    let value: Any
    
    init(displayName: String, value: Any) {
        self.displayName = displayName
        self.value = value
    }
    
    static func == (lhs: NavigationItem, rhs: NavigationItem) -> Bool {
        lhs.id == rhs.id
    }
}

class NavigationViewModel: ObservableObject {
    
    @Published var items: [NavigationItem]
    @Published var activeItem: NavigationItem
    
    var navigationPublisher = PassthroughSubject<NavigationItem, Never>()
    
    var onNewItem: (() -> Void)?
    var onItemTap: (() -> Void)?
    
    init(items: [NavigationItem], onItemTap: (() -> Void)? = nil, onNewItem: (() -> Void)? = nil) {
        self.items = items
        self.activeItem = items.first ?? NavigationItem(displayName: "", value: "")
        self.onNewItem = onNewItem
        self.onItemTap = onItemTap
    }
    
    func itemTapped(item: NavigationItem) {
        self.activeItem = item
        self.onItemTap?()
        self.navigationPublisher.send(item)
    }
    
    func updateItems() {
        self.items = PaletteService.shared.palettes.map {
            NavigationItem(displayName: $0.paletteName, value: $0)
        }
    }
    
    func setActivePalette(_ palette: Palette) {
        if let cur = self.items.first(where: { $0.value as? Palette == palette }) {
            self.activeItem = cur
        }
    }
}
