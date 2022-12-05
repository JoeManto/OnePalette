//
//  ColorGroupSelectorView.swift
//  OnePalette
//
//  Created by Joe Manto on 12/3/22.
//  Copyright © 2022 Joe Manto. All rights reserved.
//

import Foundation
import SwiftUI

struct ColorGroupSelectorViewModel {
    var groups: [OPColorGroup]
}

struct ColorGroupSelectorButton: View {
    let group: OPColorGroup
    
    @State var height = 30.0
    
    var body: some View {
        Color(group.getHeaderColor().color)
            .frame(width: 10.0, height: self.height)
            .onHover { isInside in
                withAnimation(Animation.easeIn(duration: 0.2)) {
                    self.height = isInside ? 40.0 : 30.0
                }
            }
    }
}

struct ColorGroupSelectorView: View {
    var vm: ColorGroupSelectorViewModel
    
    var body: some View {
        
        HStack {
            ForEach(vm.groups) { group in
                ColorGroupSelectorButton(group: group)
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
        ColorGroupSelectorView(vm: ColorGroupSelectorViewModel(groups: Array(palette.paletteData!.values)))
    }
}
