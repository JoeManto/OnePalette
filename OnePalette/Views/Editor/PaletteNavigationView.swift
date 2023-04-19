//
//  PaletteNavigation.swift
//  OnePalette
//
//  Created by Joe Manto on 12/18/22.
//  Copyright © 2022 Joe Manto. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import AppKit

struct PaletteNavigationView: View {
    
    @ObservedObject var vm: PaletteNavigationViewModel
    
    init(vm: PaletteNavigationViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        VStack {
            List {
                ForEach(self.vm.palettes) { palette in
                    HStack {
                        Spacer()
                        VStack {
                            Text(palette.paletteName)
                                .padding(8)
                        }
                        .background(vm.activePalette == palette.paletteName ? .blue : .clear, in: Rectangle())
                        .cornerRadius(8)
                        .onTapGesture {
                            vm.paletteTapped(palette: palette)
                        }
                        Spacer()
                    }
                    .listRowInsets(EdgeInsets())
                }
            }
            .setBackgroundColor(color: Color(nsColor: NSColor.controlBackgroundColor))
            
            Spacer()
            addPaletteBtn()
        }
        .background(Color(nsColor: NSColor.controlBackgroundColor))
    }
    
    @ViewBuilder func addPaletteBtn() -> some View {
            HStack {
                Spacer()
                Text("+")
                    .padding([.bottom, .top], 10)
                Spacer()
            }
            .background(Color(NSColor.windowBackgroundColor))
            .onTapGesture {
                vm.addNewPalette()
            }
    }
}

@available(macOS 13.0, *)
struct PaletteNavigation_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack {
            PaletteNavigationView(vm: PaletteNavigationViewModel(palettes: PaletteService.shared.palettes))
                .frame(width: 125, height: 150)
        }
        .padding(5)
        .background(.green)
    }
}
