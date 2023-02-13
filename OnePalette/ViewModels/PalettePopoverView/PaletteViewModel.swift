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
    
    var onNext: (Palette) -> ()
    var onPrev: (Palette) -> ()
    
    init(palette: Palette, onNext: @escaping (Palette) -> (), onPrev: @escaping (Palette) -> ()) {
        self.palette = palette
        self.colorGridVm = ColorGroupGridViewModel(palette: palette)
        self.onNext = onNext
        self.onPrev = onPrev
        
        self.selectionVm = ColorGroupSelectorViewModel(
            groups: Array(palette.paletteData?.values ?? [String : OPColorGroup]().values),
            onSelection: { [weak self] id in
                self?.onSelection(id: id)
            }
        )
    }
    
    private func onSelection(id: String) {
        PaletteService.shared.setCurrentGroup(groupId: id)
        if let updatedPal = PaletteService.shared.lastUsed {
            self.palette = updatedPal
            self.updateViewModels()
        }
    }
    
    func updateViewModels() {
        self.selectionVm = ColorGroupSelectorViewModel(groups:
            Array(self.palette.paletteData?.values ?? [String : OPColorGroup]().values),
            onSelection: { [weak self] id in
                self?.onSelection(id: id)
            }
        )
        
        self.colorGridVm = ColorGroupGridViewModel(palette: self.palette)
    }
    
    func nextPalette() {
        palette = PaletteService.shared.nextPalette()
        updateViewModels()
        self.onNext(palette)
    }
    
    func prevPalette() {
        palette = PaletteService.shared.prevPalette()
        updateViewModels()
        self.onPrev(palette)
    }
}
