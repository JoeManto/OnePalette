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
    
    @State private var isActive: String
    
    init(vm: PaletteNavigationViewModel) {
        self.vm = vm
        self.isActive = vm.palettes.first?.paletteName ?? ""
    }
    
    var body: some View {
        List {
            ForEach(self.vm.palettes) { palette in
                //Group {
                HStack {
                    Spacer()
                    VStack {
                        Text(palette.paletteName)
                            .padding(8)
                    }
                    .background(isActive == palette.paletteName ? .blue : .clear, in: Rectangle())
                    .cornerRadius(8)
                    .onTapGesture {
                        isActive = palette.paletteName
                        self.vm.navigationPublisher.send(palette)
                    }
                    Spacer()
                }
                .listRowInsets(EdgeInsets())
            }
        }
        .setBackgroundColor(color: Color(nsColor: NSColor.controlBackgroundColor))
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
