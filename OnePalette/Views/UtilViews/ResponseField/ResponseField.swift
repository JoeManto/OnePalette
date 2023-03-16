//
//  ResponseField.swift
//  OnePalette
//
//  Created by Joe Manto on 3/8/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import SwiftUI

struct ResponseField: View {
    let vm: ResponseFieldViewModel
    
    @State var selection: String
    
    init(vm: ResponseFieldViewModel) {
        self.vm = vm
        self.selection = vm.selection?.options.first ?? "selection"
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(vm.content.title)
                    .font(Font.standardFontMedium(size: 14, relativeTo: .body))
                Spacer()
            
                inputView()
                    .padding(.top, 8)
                    .fixedSize()
            }
            .padding([.bottom], 3)
            
            HStack {
                Text(vm.content.subtitle)
                    .font(Font.standardFontMedium(size: 14, relativeTo: .body))
                    .foregroundColor(.gray)
                Spacer()
            }
        }
    }

    private func inputView() -> some View {
        VStack {
            if vm.fieldType == .selection {
                self.selectionView()
            }
            else if vm.fieldType == .action, let action = vm.action {
                self.actionView(action: action)
            }
        }
    }
    
    private func actionView(action: ResponseFieldAction) -> some View {
        VStack {
            Text(action.name)
                .foregroundColor(action.destructive ? .red : .primary)
                .padding(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(action.destructive ? .red : .gray, lineWidth: 1.5)
                )
                .onTapGesture {
                    vm.action?.onAction()
                }
        }
    }
    
    private func selectionView() -> some View {
        VStack {
            DropDownView(title: selection, items: vm.selection?.options ?? [], onSelection: { i, newSelection in
                selection = newSelection
                vm.selection?.onSelection(i, newSelection)
            })
            .fixedSize()
            Spacer()
        }
    }
}

struct ResponseField_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack {
            ResponseField(vm: ResponseFieldViewModel(content: ResponseFieldContent(title: "Sort palette by brightness", subtitle: "Reorders the color groups of the current palette\nby the brightness of header color of each group ", type: .action), action: ResponseFieldAction(name: "Action", onAction: {
                print("Action")
            })))
            
            ResponseField(vm: ResponseFieldViewModel(content: ResponseFieldContent(title: "Sort palette by brightness", subtitle: "Reorders the color groups of the current palette\nby the brightness of header color of each group ", type: .action), action: ResponseFieldAction(name: "Action", destructive: true, onAction: {
                print("Action")
            })))
            
            ResponseField(vm: ResponseFieldViewModel(content: ResponseFieldContent(
                title: "Sort palette by brightness",
                subtitle: "Reorders the color groups of the current palette\nby the brightness of header color of each group ",
                type: .selection
            ), selection: ResponseFieldSelection(
                options: ["Hello World", "Whats good"],
                onSelection: { idx, selection in
                    print("Selection \(idx) \(selection)")
                }
            )))
        }
        .padding(50)
    }
}
