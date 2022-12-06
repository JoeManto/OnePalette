//
//  PaletteView.swift
//  OnePalette
//
//  Created by Joe Manto on 12/3/22.
//  Copyright © 2022 Joe Manto. All rights reserved.
//

import Foundation
import SwiftUI

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
        PaletteService.shared.updateCurrentGroup(groupId: id)
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

struct PaletteView: View {
    @ObservedObject var vm: PaletteViewModel
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    vm.prevPalette()
                }, label: {
                    Image(systemName: "arrow.left")
                })
                
                Button(action: {
                    vm.nextPalette()
                }, label: {
                    Image(systemName: "arrow.right")
                })
                
                Text(vm.palette.paletteName)
                Spacer()
            }
            
            ColorGroupGridView(vm: vm.colorGridVm)
            ColorGroupSelectorView(vm: vm.selectionVm)
                .frame(maxWidth: .infinity, alignment: .center)
                .frame(height: 50)
        }
        .padding(10)
    }
}

struct PaletteView_Previews: PreviewProvider {
    
    static let palette: Palette = {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Pal", in: managedContext)
        
        return Palette.init(name: "Material", localFile: "MaterialDesginColors", entity: entity!, insertInto: managedContext)
    }()
    
    static var previews: some View {
        PaletteView(vm: PaletteViewModel(palette: Self.palette,
        onNext: { pal in
            
        }, onPrev: { pal in 
            
        }))
    }
}
