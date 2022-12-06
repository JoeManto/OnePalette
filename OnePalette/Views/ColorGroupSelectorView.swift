//
//  ColorGroupSelectorView.swift
//  OnePalette
//
//  Created by Joe Manto on 12/3/22.
//  Copyright © 2022 Joe Manto. All rights reserved.
//

import Foundation
import SwiftUI

struct ColorGroupSelectorButton: View {
    let group: OPColorGroup
    let vm: ColorGroupSelectorViewModel
    
    @State var height = 20.0
    
    var body: some View {
        Color(group.getHeaderColor().color)
            .frame(width: .infinity, height: self.height)
            .onHover { isInside in
                withAnimation(Animation.easeIn(duration: 0.2)) {
                    self.height = isInside ? 30.0 : 20.0
                }
            }
            .onTapGesture {
                print("on selection \(group.getIdentifier())")
                vm.onSelection(group.getIdentifier())
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
