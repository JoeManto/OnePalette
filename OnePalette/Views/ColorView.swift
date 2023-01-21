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
    
    private let textColor: Color
    private let size: CGSize
    
    init(colorModel: OPColor, isHeader: Bool = false, isEmpty: Bool = false) {
        self.colorModel = colorModel
        self.isHeader = isHeader
        self.isEmpty = isEmpty
        self.id = colorModel.id
        
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
                if !isEmpty {
                    Text("\(self.colorModel.getWeight())")
                        .foregroundColor(self.textColor)
                        .font(.system(size: 10))
                    Text("\(self.colorModel.getHexString())")
                        .foregroundColor(self.textColor)
                        .font(.system(size: 10))
                }
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
