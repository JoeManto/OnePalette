//
//  PaletteNavigationViewModel.swift
//  OnePalette
//
//  Created by Joe Manto on 4/18/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import Combine

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
