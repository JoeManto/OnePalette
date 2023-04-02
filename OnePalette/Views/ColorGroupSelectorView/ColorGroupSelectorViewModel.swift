//
//  ColorGroupSelectorViewModel.swift
//  OnePalette
//
//  Created by Joe Manto on 12/5/22.
//  Copyright © 2022 Joe Manto. All rights reserved.
//

import Foundation

class ColorGroupSelectorViewModel: ObservableObject {
    @Published var groups: [OPColorGroup]
    
    var onSelection: (String) -> ()
    
    let isVertical: Bool
    
    @Published var selectedGroupId = ""
    
    init(groups: [OPColorGroup], isVertical: Bool = false, onSelection: @escaping (String) -> ()) {
        self.isVertical = isVertical
        self.groups = groups.filter { $0.colorsArray.count > 0 }
        self.onSelection = onSelection
    }
}