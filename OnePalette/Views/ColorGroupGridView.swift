//
//  ColorGroupGridView.swift
//  OnePalette
//
//  Created by Joe Manto on 12/3/22.
//  Copyright © 2022 Joe Manto. All rights reserved.
//

import Foundation
import SwiftUI

struct ColorView: View {
    let colorModel: OPColor
    let isHeader: Bool
    
    private let textColor: Color
    private let size: CGSize
    
    init(colorModel: OPColor, isHeader: Bool = false) {
        self.colorModel = colorModel
        self.isHeader = isHeader
        
        if isHeader {
            self.size = CGSize(width: 150, height: 150)
        }
        else {
            self.size = CGSize(width: 85, height: 85)
        }
        
        // Calcs the luminosity of the background so the color of the text is always visible
        if colorModel.calcLum() > CGFloat(0.80) {
            self.textColor = Color(red: 33.0/255.0, green: 33.0/255.0, blue: 33.0/255.0)
        }
        else {
            self.textColor = .primary
        }
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                Text("\(self.colorModel.getWeight())")
                    .foregroundColor(self.textColor)
                    .font(.system(size: 10))
                Text("\(self.colorModel.getHexString())")
                    .foregroundColor(self.textColor)
                    .font(.system(size: 10))
                Spacer()
            }
            .frame(minWidth: self.size.width, maxWidth: self.size.width, minHeight: self.size.height, maxHeight: self.size.height)
            .padding([.top], 10)
            .padding([.leading], -10)
        }
        .background(Color(colorModel.color))
        .cornerRadius(self.isHeader ? 30 : 10)
    }
}

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
