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
        
    var headers: [OPColorGroup] {
        groups.compactMap {
            guard $0.headerColorIndex < $0.colorsArray.count else {
                return nil
            }
            return $0
        }
    }
    
    init(groups: [OPColorGroup], isVertical: Bool = false, onSelection: @escaping (String) -> ()) {
        self.isVertical = isVertical
        self.groups = groups.filter { $0.colorsArray.count > 0 }
        self.onSelection = onSelection
    }
    
    func updateUI() {
        /// Trigger an update to selectedGroupId
        let groupId = self.selectedGroupId
        self.selectedGroupId = groupId
    }
}
