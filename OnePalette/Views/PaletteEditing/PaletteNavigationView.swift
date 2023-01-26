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

class PaletteNavigationViewModel: ObservableObject {
    
    let palettes: [Palette]
    @Published var selectedIndex = 0
    
    var navigationPublisher = PassthroughSubject<Any, Never>()
    
    init(palettes: [Palette]) {
        self.palettes = palettes
    }
    
    func paletteTap() {
        navigationPublisher.send(self.palettes[self.selectedIndex])
    }
}

struct PaletteNavigationView: View {
    
    @ObservedObject var vm: PaletteNavigationViewModel
    
    var body: some View {
        List {
            ForEach(self.vm.palettes) { palette in
                Text(palette.paletteName)
                    .onTapGesture {
                        self.vm.navigationPublisher.send(palette)
                    }
            }
        }
        .setBackgroundColor(color: Color(nsColor: NSColor.controlBackgroundColor))
    }
}

struct PaletteNavigation_Previews: PreviewProvider {
    
    static var previews: some View {
        PaletteNavigationView(vm: PaletteNavigationViewModel(palettes: PaletteService.shared.palettes))
    }
}
