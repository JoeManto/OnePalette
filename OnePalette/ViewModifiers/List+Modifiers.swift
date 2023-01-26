//
//  List+Modifiers.swift
//  OnePalette
//
//  Created by Joe Manto on 1/21/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import SwiftUI
import Introspect

extension List {
    
    func setBackgroundColor(color: Color) -> some View {
        return introspectTableView { tableView in
            tableView.backgroundColor = .clear
            tableView.enclosingScrollView!.drawsBackground = false
        }
        .background(color)
    }
}
