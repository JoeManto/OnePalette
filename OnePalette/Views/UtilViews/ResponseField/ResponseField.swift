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
    @State private var actionInProgress: Bool = false
    
    @State private var btnSize = CGSize(width: 0, height: 0)
    @State private var offsetX = 0.0
    @State private var deleting = false
    
    @State private var waveIndicatorScale = 1.0
    @State private var waveIndicatorOpacity = 0.0
    
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
                    .frame(maxWidth: 400, alignment: .leading)
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
    
    func deletionAnimation() {
        var transaction = Transaction(animation: .linear)
        transaction.disablesAnimations = true

        withTransaction(transaction) {
            self.offsetX = self.btnSize.width
            withAnimation(.linear(duration: 3.0)) {
                self.offsetX = 0
            }
        }
    }
    
    func deletionCompleteAnimation() {
        self.waveIndicatorOpacity = 1.0
        withAnimation(.easeInOut(duration: 1.0)) {
            self.waveIndicatorScale = 1.5
            self.waveIndicatorOpacity = 0.0
            DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(1))) {
                self.waveIndicatorOpacity = 0.0
                self.waveIndicatorScale = 1.0
            }
        }
    }
    
    @ViewBuilder private func actionView(action: ResponseFieldAction) -> some View {
        VStack {
            ZStack {
                Color.red
                    .opacity(1.0)
                    .cornerRadius(8)
                    .offset(x: offsetX)
                
                Text(action.name)
                    .foregroundColor({
                        if action.destructive {
                            return deleting ? .white : AppColors.destructive.highlighting(actionInProgress)
                        }
                        else {
                            return AppColors.gray1.highlighting(actionInProgress)
                        }
                    }())
                    .padding([.leading, .trailing])
                    .padding([.top, .bottom], 10)
                    
            }
            .cornerRadius(8)
            .readIntrinsicContentSize(to: $btnSize)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke({ () -> Color in
                        if action.destructive {
                            return AppColors.destructive.highlighting(actionInProgress)
                        }
                        else {
                            return AppColors.gray1.highlighting(actionInProgress)
                        }
                    }(), lineWidth: 1.5)
                    
            )
            .onHold(
                onTap: {
                    print("onTap")
                    if action.destructive, self.deleting == false {
                        self.deleting = true
                        
                        deletionAnimation()
                    }
                },
                onRelease: { time in
                    guard action.destructive else {
                        action.onAction()
                        return
                    }
                    
                    self.deleting = false
                    self.offsetX = self.btnSize.width
                    
                    if time >= 3.0 {
                        action.onAction()
                        deletionCompleteAnimation()
                    }
                },
                maxHoldTime: 3
            )
            .onAppear {
                self.offsetX = self.btnSize.width
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppColors.destructive.highlighting(false), lineWidth: 1.0)
                .scaleEffect(self.waveIndicatorScale)
                .opacity(self.waveIndicatorOpacity)
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
