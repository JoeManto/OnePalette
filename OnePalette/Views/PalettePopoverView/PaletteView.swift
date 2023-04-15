//
//  PaletteView.swift
//  OnePalette
//
//  Created by Joe Manto on 12/3/22.
//  Copyright © 2022 Joe Manto. All rights reserved.
//

import Foundation
import SwiftUI

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
            
            switch vm.colorGridVm.gridSize {
            case .small:
                ColorGroupSmallGridView(vm: vm.colorGridVm)
            case .medium:
                ColorGroupMediumGridView(vm: vm.colorGridVm)
            case .large:
                ColorGroupLargeGridView(vm: vm.colorGridVm)
            }
            
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
