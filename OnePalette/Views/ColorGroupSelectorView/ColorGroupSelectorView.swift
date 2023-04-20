//
//  ColorGroupSelectorView.swift
//  OnePalette
//
//  Created by Joe Manto on 12/3/22.
//  Copyright © 2022 Joe Manto. All rights reserved.
//

import Foundation
import SwiftUI
import AppSDK

struct ColorGroupSelectorButton: View {
    let group: OPColorGroup
    @ObservedObject var vm: ColorGroupSelectorViewModel
    
    @State var dynamicSize = 20.0
    
    var body: some View {
        Color(group.headerColor.color)
            .frame(height: vm.selectedGroupId == group.identifier ? 30.0 : self.dynamicSize)
            .onHover { isInside in
                withAnimation(Animation.easeIn(duration: 0.2)) {
                    self.dynamicSize = isInside ? 30.0 : 20.0
                }
            }
            .onTapGesture {
                let id = group.identifier
                print("on selection \(id)")
                vm.onSelection(id)
                vm.selectedGroupId = id
            }
    }
}

struct ColorGroupSelectorView: View {
    let vm: ColorGroupSelectorViewModel
    
    var body: some View {
        HStack {
            ForEach(vm.groups) { group in
                ColorGroupSelectorButton(group: group, vm: vm)
            }
            .padding([.trailing, .leading], -4)
        }
        .frame(height: 50)
    }
}

struct ColorGroupSelectorView_Previews: PreviewProvider {
    
    static let palette: Palette = {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Pal", in: managedContext)
        
        return Palette.init(name: "Material", localFile: "MaterialDesginColors", entity: entity!, insertInto: managedContext)
    }()
    
    static var previews: some View {
        ColorGroupSelectorView(vm: ColorGroupSelectorViewModel(groups: Array(palette.paletteData!.values), onSelection: { id in
            
        }))
    }
}
