//
//  ColorViewq.swift
//  OnePalette
//
//  Created by Joe Manto on 1/21/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import SwiftUI

struct ColorView: View, Identifiable {
    let id: ObjectIdentifier
    
    let colorModel: OPColor
    let isHeader: Bool
    let isEmpty: Bool
    let isSelected: Bool
    let isEditing: Bool
    let onDelete: (() -> Void)?
    
    private let textColor: Color
    private let size: CGSize
    
    init(colorModel: OPColor, isHeader: Bool = false, isEmpty: Bool = false, isSelected: Bool = false, isEditing: Bool = false, onDelete: (() -> Void)? = nil) {
        self.colorModel = colorModel
        self.isHeader = isHeader
        self.isEmpty = isEmpty
        self.id = colorModel.id
        self.isSelected = isSelected
        self.isEditing = isEditing
        self.onDelete = onDelete
        
        if isHeader {
            self.size = CGSize(width: 150, height: 150)
        }
        else {
            self.size = CGSize(width: 85, height: 85)
        }
        
        // Calcs the luminosity of the background so the color of the text is always visible
        if colorModel.lum > 0.80 {
            self.textColor = Color(red: 33.0/255.0, green: 33.0/255.0, blue: 33.0/255.0)
        }
        else {
            self.textColor = .primary
        }
    }
    
    var body: some View {
        ZStack {
            HStack {
                VStack {
                    if !isEmpty {
                        HStack {
                            Text("\(self.colorModel.getWeight())")
                                .foregroundColor(self.textColor)
                                .font(.system(size: 10))
                            Spacer()
                        }
                        
                        HStack {
                            Text("\(self.colorModel.getHexString())")
                                .foregroundColor(self.textColor)
                                .font(.system(size: 10))
                            Spacer()
                        }
                    }
                    Spacer()
                }
                .padding([.leading, .top], isHeader ? 15 : 10)
                Spacer()
            }
        }
        .frame(minWidth: self.size.width, maxWidth: self.size.width, minHeight: self.size.height, maxHeight: self.size.height)
        .background(Color(nsColor: colorModel.color))
        .cornerRadius(self.isHeader ? 30 : 10)
        .overlay(content: {
            if isSelected {
                RoundedRectangle(cornerRadius: self.isHeader ? 30 : 10)
                    .stroke(.selection, lineWidth: 3)
            }
        })
        .overlay(alignment: .topTrailing, content: {
            if isSelected && isEditing {
                ZStack {
                    Image(systemName: "xmark.circle")
                        .padding(3)
                }
                .clipShape(Circle())
                .background(.red, in: Circle())
                .offset(CGSize(width: 10, height: -12))
                .onTapGesture {
                    onDelete?()
                }
            }
        })
    }
}

struct ColorView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ColorView(colorModel: OPColor(nsColor: .red, weight: 100), isHeader: true)
            ColorView(colorModel: OPColor(nsColor: .red, weight: 100), isHeader: true, isSelected: true)
            ColorView(colorModel: OPColor(nsColor: .red, weight: 100))
            ColorView(colorModel: OPColor(nsColor: .red, weight: 100), isSelected: true)
            ColorView(colorModel: OPColor.empty(), isEmpty: true)
        }
        .padding(100)
    }
}
