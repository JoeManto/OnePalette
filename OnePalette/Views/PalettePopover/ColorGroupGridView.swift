//
//  ColorGroupGridView.swift
//  OnePalette
//
//  Created by Joe Manto on 12/3/22.
//  Copyright © 2022 Joe Manto. All rights reserved.
//

import Foundation
import SwiftUI
import AppSDK

struct ColorGroupLargeGridView: View {
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
                    if let header = vm.header {
                        ColorView(colorModel: header, groupName: vm.group.name, isHeader: true)
                            .padding(.trailing, 20)
                    }
                }
                LazyVGrid(columns: gridItems, content: {
                    ForEach(vm.nonHeaderColors) { row in
                        ColorView(colorModel: row, groupName: vm.group.name)
                    }
                })
            }
        }
        .padding(10)
    }
}

struct ColorGroupMediumGridView: View {
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
                    if let header = vm.header {
                        ColorView(colorModel: header, groupName: vm.group.name, isHeader: true)
                            .padding(.trailing, 20)
                    }
                }
                LazyVGrid(columns: gridItems, content: {
                    ForEach(vm.nonHeaderColors) { row in
                        ColorView(colorModel: row, groupName: vm.group.name)
                    }
                })
            }
        }
        .padding(10)
    }
}

struct ColorGroupSmallGridView: View {
    var vm: ColorGroupGridViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text(vm.name)
                    .font(.title)
                    .bold()
                Spacer()
            }
            
            HStack {
                ForEach(vm.allColors) { row in
                    ColorView(colorModel: row, groupName: vm.group.name, responsive: true)
                }
            }
            
        }
        .padding(10)
    }
}

struct ColorGroupEmptyGridView: View {
    var vm: ColorGroupGridViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text(vm.name)
                    .font(.title)
                    .bold()
                Spacer()
            }
            
            HStack {
                Spacer()
                Text("Empty Group")
                /*ForEach(vm.allColors) { row in
                    ColorView(colorModel: row, groupName: vm.group.name, responsive: true)
                }*/
                Spacer()
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
        
        /*let palette = Palette.init(name: "Material", localFile: "MaterialDesginColors", entity: entity!, insertInto: managedContext)*/
        
        let smallPalGroup = OPColorGroup.newGroup()
        smallPalGroup.addColor(color: OPColor(nsColor: .red, weight: 100))
        smallPalGroup.addColor(color: OPColor(nsColor: .orange, weight: 200))
        
        let smallPal = Palette(name: "Palette Name", data: [
            "group1": smallPalGroup,
        ], groupsOrder: ["group1"], palWeights: [50, 100, 200], palKeys: ["group1"], date: Date(), entity: entity!, insertInto: managedContext)
        
        return smallPal
    }()
    
    static var previews: some View {
        ColorGroupSmallGridView(vm: ColorGroupGridViewModel(palette: Self.palette, gridSize: .small))
            .previewDisplayName("small")
        ColorGroupMediumGridView(vm: ColorGroupGridViewModel(palette: Self.palette, gridSize: .medium))
            .previewDisplayName("medium")
        ColorGroupLargeGridView(vm: ColorGroupGridViewModel(palette: Self.palette, gridSize: .large))
            .previewDisplayName("large")
    }
}
