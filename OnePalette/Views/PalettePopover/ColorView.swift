//
//  ColorViewq.swift
//  OnePalette
//
//  Created by Joe Manto on 1/21/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import SwiftUI
import AppSDK

struct ColorView: View, Identifiable {
    let id: ObjectIdentifier
    
    let colorModel: OPColor
    let groupName: String
    let isHeader: Bool
    let isEmpty: Bool
    let isSelected: Bool
    let isEditing: Bool
    let onDelete: (() -> Void)?
    let responsive: Bool
    
    var onTap: (() -> Void)?
    
    private let textColor: Color
    private let size: CGSize
    
    @State private var hovered: Bool = false
    @State private var copying: Bool = false
    @State private var opacityAnimationValue = 0.0
    
    init(colorModel: OPColor, groupName: String = "", isHeader: Bool = false, isEmpty: Bool = false, isSelected: Bool = false, isEditing: Bool = false, responsive: Bool = false, onDelete: (() -> Void)? = nil, onTap: (() -> Void)? = nil) {
        self.colorModel = colorModel
        self.isHeader = isHeader
        self.isEmpty = isEmpty
        self.id = colorModel.id
        self.isSelected = isSelected
        self.isEditing = isEditing
        self.onDelete = onDelete
        self.responsive = responsive
        self.groupName = groupName
        self.onTap = onTap
        
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
                if !isEditing, !isEmpty, copying {
                    Text("Copied")
                        .opacity(copying ? 1.0 : 0.0)
                        .foregroundColor(self.textColor)
                        .font(.standardFontBold(size: 18, relativeTo: .body))
                }
                else {
                    VStack {
                        if !isEmpty {
                            HStack {
                                Text("\(self.colorModel.getWeight())")
                                    .foregroundColor(self.textColor)
                                    .font(.system(size: 10))
                                    .opacity(copying ? 0.0 : 1.0)
                                Spacer()
                            }
                            
                            HStack {
                                Text("\(self.colorModel.getHexString())")
                                    .foregroundColor(self.textColor)
                                    .font(.system(size: 10))
                                    .opacity(copying ? 0.0 : 1.0)
                                Spacer()
                            }
                        }
                        Spacer()
                    }
                    .padding([.leading, .top], isHeader ? 15 : 10)
                    Spacer()
                }
            }
        }
        .frame(minWidth: self.size.width, maxWidth: responsive ? .infinity : self.size.width, minHeight: self.size.height, maxHeight: responsive ? 150 : self.size.height)
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
                
                .opacity(hovered ? 1.0 : 0.0)
                .animation(.easeIn(duration: 0.3), value: hovered)
                .onTapGesture {
                    onDelete?()
                }
            }
        })
        .onHover { inView in
            hovered = inView
        }
        .onTapGesture {
            self.onTap?()
            guard !isEditing else {
                return
            }
            
            colorModel.copyToPasteboard(groupName: groupName)
            withAnimation(.easeIn(duration: 0.25)) {
                self.copying = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(1))) {
                withAnimation(.easeIn(duration: 0.25)) {
                    self.copying = false
                }
            }
        }
        .shake(intensity: self.copying ? .soft : .none)
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
