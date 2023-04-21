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
    let id: String
    let displayName: String
    
    init(displayName: String) {
        self.id = displayName
        self.displayName = displayName
    }
}

class NavigationViewModel: ObservableObject {
    
    @Published var items: [String]
    @Published var activeItem: NavigationItem
    
    var navigationPublisher = PassthroughSubject<NavigationItem, Never>()
    
    var onNewItem: (() -> Void)?
    var onItemTap: (() -> Void)?
    
    var displayItems: [NavigationItem] {
        self.items.map { NavigationItem(displayName: $0) }
    }
    
    init(items: [String], onItemTap: (() -> Void)? = nil, onNewItem: (() -> Void)? = nil) {
        self.items = items
        self.activeItem = NavigationItem(displayName: items.first ?? "")
        self.onNewItem = onNewItem
        self.onItemTap = onItemTap
    }
    
    func itemTapped(item: NavigationItem) {
        self.activeItem = item
        self.onItemTap?()
        self.navigationPublisher.send(item)
    }
}
