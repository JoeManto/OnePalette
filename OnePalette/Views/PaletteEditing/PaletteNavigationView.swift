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
    
    @Published var palettes: [Palette]
    @Published var activePalette: String
    
    var navigationPublisher = PassthroughSubject<Any, Never>()
    
    init(palettes: [Palette]) {
        self.palettes = palettes
        self.activePalette = palettes.first?.paletteName ?? ""
    }
    
    func paletteTapped(palette: Palette) {
        self.activePalette = palette.paletteName
        self.navigationPublisher.send(palette)
    }
    
    /// Requests a new palette to be created.
    /// Called when user taps on add new palette
    func addNewPalette() {
        let palette = PaletteService.shared.installEmptyPalette()
        self.palettes = PaletteService.shared.palettes
        self.paletteTapped(palette: palette)
    }
    
    /// Updates all the palettes and sets the active palette
    func update(activePalette: String) {
        self.palettes = PaletteService.shared.palettes
        self.activePalette = activePalette
    }
}

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
            HStack {
                addPaletteBtn()
            }
        }
    }
    
    @ViewBuilder func addPaletteBtn() -> some View {
        Text("Add Palette")
            .padding(.bottom, 10)
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
