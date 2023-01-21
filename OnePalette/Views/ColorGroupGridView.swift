//
//  ColorGroupGridView.swift
//  OnePalette
//
//  Created by Joe Manto on 12/3/22.
//  Copyright © 2022 Joe Manto. All rights reserved.
//

import Foundation
import SwiftUI

struct ColorGroupGridView: View {
    var vm: ColorGroupGridViewModel
    
    private let gridItems = [GridItem(.fixed(100)), GridItem(.fixed(100)), GridItem(.fixed(100)), GridItem(.fixed(100))]
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    HStack {
                        Text(vm.name)
                            .font(.title)
                            .bold()
                        Spacer()
                    }
                    ColorView(colorModel: vm.header, isHeader: true)
                        .padding(.trailing, 20)
                }
                LazyVGrid(columns: gridItems, content: {
                    ForEach(vm.nonHeaderColors) { row in
                        ColorView(colorModel: row)
                    }
                })
            }
        }
        .padding(10)
    }
}

struct ColorGroupGrid_Previews: PreviewProvider {
    
    static let palette: Palette = {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Pal", in: managedContext)
        
        return Palette.init(name: "Material", localFile: "MaterialDesginColors", entity: entity!, insertInto: managedContext)
    }()
    
    static var previews: some View {
        ColorGroupGridView(vm: ColorGroupGridViewModel(palette: Self.palette))
    }
}
