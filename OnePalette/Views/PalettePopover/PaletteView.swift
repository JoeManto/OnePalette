//
//  PaletteView.swift
//  OnePalette
//
//  Created by Joe Manto on 12/3/22.
//  Copyright © 2022 Joe Manto. All rights reserved.
//

import Foundation
import SwiftUI
import AppSDK

struct PaletteView: View {
    @ObservedObject var vm: PaletteViewModel
    
    private var size: CGSize {
        switch vm.colorGridVm.gridSize {
        case .small:
            return CGSize(width: 500, height: 250)
        case .medium:
            return CGSize(width: 600, height: 320)
        case .large:
            return CGSize(width: 600, height: 400)
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
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
                    .font(.standardFontBold(size: 14, relativeTo: .title))
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
            Spacer()
        }
        .frame(width: size.width, height: size.height)
        .fixedSize()
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
        PaletteView(vm: PaletteViewModel(palette: Self.palette))
    }
}
