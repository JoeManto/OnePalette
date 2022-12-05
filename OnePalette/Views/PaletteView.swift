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
    var selectionVm: ColorGroupSelectorViewModel
    var colorGridVm: ColorGroupGridViewModel
    
    init(palette: Palette, onNext: @escaping () -> (), onPrev: @escaping () -> ()) {
        self.palette = palette
        self.selectionVm = ColorGroupSelectorViewModel(groups:
            Array(palette.paletteData?.values ?? [String : OPColorGroup]().values)
        )
        
        self.colorGridVm = ColorGroupGridViewModel(palette: palette)
        
        self.onNext = onNext
        self.onPrev = onPrev
    }
    
    func updateViewModels() {
        self.selectionVm = ColorGroupSelectorViewModel(groups:
            Array(self.palette.paletteData?.values ?? [String : OPColorGroup]().values)
        )
        
        self.colorGridVm = ColorGroupGridViewModel(palette: self.palette)
    }
    
    var onNext: () -> ()
    var onPrev: () -> ()
}

struct PaletteView: View {
    @ObservedObject var vm: PaletteViewModel
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    vm.palette = PaletteService.shared.prevPalette()
                    vm.updateViewModels()
                }, label: {
                    Image(systemName: "arrow.left")
                })
                
                Button(action: {
                    vm.palette = PaletteService.shared.nextPalette()
                    vm.updateViewModels()
                }, label: {
                    Image(systemName: "arrow.right")
                })
                
                Text(vm.palette.paletteName)
                Spacer()
            }
            
            ColorGroupGridView(vm: vm.colorGridVm)
            ColorGroupSelectorView(vm: vm.selectionVm)
                .frame(maxWidth: .infinity, alignment: .center)
                .frame(height: 100)
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
        onNext: {
            
        }, onPrev: {
            
        }))
    }
}
