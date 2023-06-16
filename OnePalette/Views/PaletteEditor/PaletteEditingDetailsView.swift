//
//  PaletteEditingDetailsView.swift
//  OnePalette
//
//  Created by Joe Manto on 5/30/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import SwiftUI

struct PaletteEditingDetailsView: View {
    
    @ObservedObject var vm: PaletteEditingDetailsViewModel
    
    @State var selection: String = ""
    
    var body: some View {
        HStack {
            Color.black
                .frame(width: 1)
            ScrollView {
                Text("Hello World")
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .background(.background)
        }
        .frame(width: 200)
        .background(.background)
    }
}
