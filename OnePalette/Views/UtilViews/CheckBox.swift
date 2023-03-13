//
//  CheckBox.swift
//  OnePalette
//
//  Created by Joe Manto on 3/12/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import SwiftUI

struct CheckBox: View {
    var isOn: Binding<Bool>
    
    @State private var checked: Bool = false
    
    init(isOn: Binding<Bool>) {
        self.isOn = isOn
        self.checked = isOn.wrappedValue
    }
    
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(Color(NSColor.controlAccentColor))
                    .padding(2.5)
                    .opacity(isOn.wrappedValue ? 1.0 : 0.0)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(.gray, lineWidth: 1.5)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            checked = !checked
            isOn.wrappedValue = checked
        }
        .frame(width: 15, height: 15)
    }
}

struct CheckBox_Previews: PreviewProvider {
   
    static var previews: some View {
        Group {
            CheckBox(isOn: Binding.constant(true))
                .padding()
        }
    }
}
