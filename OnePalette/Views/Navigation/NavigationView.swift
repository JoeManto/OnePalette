//
//  NavigationView.swift
//  OnePalette
//
//  Created by Joe Manto on 4/20/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import AppKit

struct NavigationView: View {
    
    @ObservedObject var vm: NavigationViewModel
    
    init(vm: NavigationViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        VStack {
            List {
                ForEach(self.vm.items, id: \.id) { item in
                    HStack {
                        Spacer()
                        VStack {
                            Text(LocalizedStringKey(item.displayName))
                                .padding(8)
                        }
                        .background(vm.activeItem == item ? .blue : .clear, in: Rectangle())
                        .cornerRadius(8)
                        .onTapGesture {
                            vm.itemTapped(item: item)
                        }
                        Spacer()
                    }
                    .listRowInsets(EdgeInsets())
                }
            }
            .setBackgroundColor(color: Color(nsColor: NSColor.controlBackgroundColor))
            
            Spacer()
            addPaletteBtn()
        }
        .background(Color(nsColor: NSColor.controlBackgroundColor))
    }
    
    @ViewBuilder func addPaletteBtn() -> some View {
            HStack {
                Spacer()
                Text("+")
                    .padding([.bottom, .top], 10)
                Spacer()
            }
            .background(Color(NSColor.windowBackgroundColor))
            .onTapGesture {
                vm.onNewItem?()
            }
    }
}

@available(macOS 13.0, *)
struct Navigation_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack {
            NavigationView(vm: NavigationViewModel(items: [
                NavigationItem(displayName: "Item 1", value: ""),
                NavigationItem(displayName: "Item 2", value: ""),
                NavigationItem(displayName: "Item 1", value: "")
            ]))
                .frame(width: 125, height: 150)
        }
        .padding(5)
    }
}
