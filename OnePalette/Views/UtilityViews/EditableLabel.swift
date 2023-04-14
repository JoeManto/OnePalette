//
//  EditableLabel.swift
//  OnePalette
//
//  Created by Joe Manto on 4/2/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

extension View {
    @ViewBuilder
    private func onBackgroundTapContent(enabled: Bool, viewFrame: CGRect, windowSize: CGSize, _ action: @escaping () -> Void) -> some View {
        if enabled {
            Color.clear
                .frame(width: windowSize.width, height: windowSize.height)
                .contentShape(Rectangle())
                .onTapGesture(count: 1, coordinateSpace: .global, perform: { tapLocation in
                    if !viewFrame.contains(tapLocation) {
                        action()
                    }
                })
        }
    }

    func onBackgroundTap(enabled: Bool, viewFrame: CGRect, _ action: @escaping () -> Void) -> some View {
        let windowSize = CGSize(width: (NSApplication.shared.delegate as? AppDelegate)!.colorWindow.contentView!.bounds.width * 2,
                            height: (NSApplication.shared.delegate as? AppDelegate)!.colorWindow.contentView!.bounds.height * 2)
        return background(
            onBackgroundTapContent(enabled: enabled, viewFrame: viewFrame, windowSize: windowSize, action)
        )
    }
}

struct EditableLabel: View {
    @Binding var text: String
        
    @State var editing = false {
        didSet {
            if text.isEmpty {
                text = "Empty"
            }
            
            guard !editing else {
                return
            }
        }
    }
    
    @State var frame: CGRect = .zero
    
    let onEditEnd: () -> Void
    
    init(_ txt: Binding<String>, onEditEnd: @escaping () -> Void) {
        _text = txt
        self.onEditEnd = onEditEnd
    }
    
    var body: some View {
        
        ZStack {
            textFieldView()
                .fixedSize()
                .opacity(self.editing ? 1 : 0)
                .onBackgroundTap(enabled: editing, viewFrame: frame) {
                    editing = false
                }
            
            labelView()
                .opacity(self.editing ? 0 : 1)
                .onTapGesture {
                    editing = true
                }
    
        }
        .readFrame($frame)
    }

    func labelView() -> some View {
        Text(text)
    }
    
    func textFieldView() -> some View {
        if !editing, text.isEmpty {
            text = "Empty"
        }
        return TextField("", text: $text,
            onEditingChanged: { status in

            },
            onCommit: {
                editing = false
                onEditEnd()
            }
        )
        .onExitCommand(perform: {
            editing = false
            onEditEnd()
        })
        .disabled(!editing)
    }
}
