//
//  ColorGroupSelectorViewModel.swift
//  OnePalette
//
//  Created by Joe Manto on 12/5/22.
//  Copyright © 2022 Joe Manto. All rights reserved.
//

import Foundation

class ColorGroupSelectorViewModel {
    var groups: [OPColorGroup]
    
    var onSelection: (String) -> ()
    
    init(groups: [OPColorGroup], onSelection: @escaping (String) -> ()) {
        self.groups = groups
        self.onSelection = onSelection
    }
}
