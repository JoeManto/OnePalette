//
//  PaletteViewModel.swift
//  OnePalette
//
//  Created by Joe Manto on 12/5/22.
//  Copyright © 2022 Joe Manto. All rights reserved.
//

import Foundation

class PaletteViewModel: ObservableObject {
    @Published var palette: Palette
    private(set) var selectionVm: ColorGroupSelectorViewModel!
    var colorGridVm: ColorGroupGridViewModel
    
    var onNext: ((Palette) -> ())?
    var onPrev: ((Palette) -> ())?
    
    init(palette: Palette) {
        self.palette = palette
        self.colorGridVm = ColorGroupGridViewModel(palette: palette)
        
        self.selectionVm = ColorGroupSelectorViewModel(
            groups: palette.groups,
            onSelection: { [weak self] id in
                self?.onColorGroupSelection(id: id)
            }
        )
    }
    
    private func onColorGroupSelection(id: String) {
        PaletteService.shared.setCurrentGroup(groupId: id)
        if let updatedPal = PaletteService.shared.lastUsed {
            self.palette = updatedPal
            self.updateViewModels()
        }
    }
    
    func updateViewModels() {
        self.selectionVm = ColorGroupSelectorViewModel(groups: self.palette.groups,
            onSelection: { [weak self] id in
                self?.onColorGroupSelection(id: id)
            }
        )
        
        self.colorGridVm = ColorGroupGridViewModel(palette: self.palette)
    }
    
    func nextPalette() {
        palette = PaletteService.shared.nextPalette()
        updateViewModels()
        self.onNext?(palette)
    }
    
    func prevPalette() {
        palette = PaletteService.shared.prevPalette()
        updateViewModels()
        self.onPrev?(palette)
    }
}
