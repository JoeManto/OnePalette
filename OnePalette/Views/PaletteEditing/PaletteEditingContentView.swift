//
//  PaletteEditingContentView.swift
//  OnePalette
//
//  Created by Joe Manto on 1/8/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import SwiftUI

class PaletteEditingContentViewModel: ObservableObject {
    @Published var palette: Palette
    
    private(set) var selectionVm: ColorGroupSelectorViewModel!
    
    @Published var selectedColorGroup: OPColorGroup
    
    init(palette: Palette!) {
        self.palette = palette
        
        let groups = palette.groups
        
        self.selectedColorGroup = groups.first ?? OPColorGroup(id: "EmptyGroup")
        
        self.selectionVm = ColorGroupSelectorViewModel(groups: groups, onSelection: { [weak self] id in
            self?.onSelection(id: id)
        })
    }
    
    private func onSelection(id: String) {
        if let group = self.palette.groups.filter({ $0.getIdentifier() == id }).first {
            self.selectedColorGroup = group
        }
    }
    
    /// Returns an array of color square views padded with empty color square views at the end if needed
    func getPaddedColorGroupView() -> [ColorView] {
        var colors = self.selectedColorGroup.getColorArray()
        var views = [ColorView]()
        
        for i in 0..<colors.count {
            views.append(ColorView(colorModel: colors[i]))
        }
        
        let remainder = 10 - colors.count
        guard remainder > 0 else {
            return views
        }
        
        for _ in 0..<remainder {
            views.append(ColorView(colorModel: OPColor.empty(), isEmpty: true))
        }
        
        return views
    }
}

struct PaletteEditingContentView: View {
    
    @ObservedObject var vm: PaletteEditingContentViewModel
  
    var body: some View {
        VStack {
            Text(vm.palette.paletteName)
            
            let views = vm.getPaddedColorGroupView()
            
            VStack {
                HStack {
                    ForEach(views[0..<5]) { colorView in
                        colorView
                    }
                }
                
                HStack {
                    ForEach(views[5..<10]) { colorView in
                        colorView
                    }
                }
                
                ColorGroupSelectorView(vm: vm.selectionVm)
            }
        }
        .frame(width: 500, height: 500)
        .background(.background)
    }    
}
