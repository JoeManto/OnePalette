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
    @Published var palette: Palette?
    
    lazy var selectedColorGroup: OPColorGroup = {
        self.palette?.paletteData?.first?.value ?? OPColorGroup(id: "EmptyGroup")
    }()
    
    init(palette: Palette?) {
        self.palette = palette
    }
    
    /// Returns an array of color square views padded with empty color square views at the end if needed
    func getPaddedColorGroupView() -> [ColorView] {
        var colors = self.selectedColorGroup.getColorArray()
        colors.removeLast()
        colors.removeLast()
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
            Text(vm.palette?.paletteName ?? "")
            
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
                
            }
        }
        .frame(width: 500, height: 500)
        .background(.background)
    }    
}
