//
//  DropDownView.swift
//  OnePalette
//
//  Created by Joe Manto on 3/11/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import SwiftUI

struct DropDownView: View {
    
    let title: String
    let items: [String]
    let onSelection: (Int, String) -> ()
    
    var body: some View {
        Menu {
            ForEach((0..<items.count), id: \.self) { i in
                Button(items[i], action: {
                    print("hello")
                    onSelection(i, items[i])
                })
                Divider()
            }
        } label: {
            Text(title)
        }
    }
    
}
