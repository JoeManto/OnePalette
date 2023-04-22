//
//  CopyFormatEditorView.swift
//  OnePalette
//
//  Created by Joe Manto on 4/20/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import SwiftUI
import AppSDK

struct CopyFormatEditorView: View {
    
    @ObservedObject var vm: CopyFormatEditorViewModel

    var body: some View {
        ScrollView {
            if let _ = vm.formatId {
                EditableLabel($vm.formatName, containingWindow: (NSApplication.shared.delegate as! AppDelegate).copyFormatWindow, onEditEnd: {
                    vm.saveFormat()
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.standardFontBold(size: 32.0, relativeTo: .title))
                .padding([.leading])
                
                VStack {
                    HStack {
                        Text("Format Keys")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.standardFontBold(size: 18.0, relativeTo: .subheadline))
                            .padding(.bottom, 1)
                    }
                    
                    HStack {
                        VStack {
                            Text("RGB")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.standardFont(size: 18.0, relativeTo: .body))
                            
                            Text("A color’s component\n from 0 to 255")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.standardFont(size: 12.0, relativeTo: .body))
                                .foregroundColor(.gray)
                                .padding(.bottom, 8)
                            
                            VStack {
                                Text("@r")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.standardFont(size: 18.0, relativeTo: .body))
                                    .foregroundColor(.red)
                                
                                Text("@g")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.standardFont(size: 18.0, relativeTo: .body))
                                    .foregroundColor(.green)
                                
                                Text("@b")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.standardFont(size: 18.0, relativeTo: .body))
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        VStack {
                            Text("Float")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.standardFont(size: 18.0, relativeTo: .body))
                            
                            Text("A color’s component\n from 0 to 1.0")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.standardFont(size: 12.0, relativeTo: .body))
                                .foregroundColor(.gray)
                                .padding(.bottom, 8)
                            
                            VStack {
                                Text("@r-float")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.standardFont(size: 18.0, relativeTo: .body))
                                    .foregroundColor(.red)
                                
                                Text("@g-float")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.standardFont(size: 18.0, relativeTo: .body))
                                    .foregroundColor(.green)
                                
                                Text("@b-float")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.standardFont(size: 18.0, relativeTo: .body))
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        VStack {
                        
                            Text("@hex")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.standardFont(size: 18.0, relativeTo: .body))
                                .foregroundColor(Color(nsColor: NSColor.hex("5AC8FF", alpha: 1.0)))
                            
                            Text("A colors hex value ex 'AB9F2C'")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.standardFont(size: 12.0, relativeTo: .body))
                                .foregroundColor(.gray)
                                .padding(.bottom, 3)
                            
                            Text("@group")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.standardFont(size: 18.0, relativeTo: .body))
                                .foregroundColor(Color(nsColor: NSColor.hex("5AC8FF", alpha: 1.0)))
                            
                            Text("The name of the containing color group")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.standardFont(size: 12.0, relativeTo: .body))
                                .foregroundColor(.gray)
                                .padding(.bottom, 3)
                            
                            Text("@color")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.standardFont(size: 18.0, relativeTo: .body))
                                .foregroundColor(Color(nsColor: NSColor.hex("5AC8FF", alpha: 1.0)))
                            
                            Text("The optional name of the color")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.standardFont(size: 12.0, relativeTo: .body))
                                .foregroundColor(.gray)
                        }
                        .fixedSize()
                    }
                    .padding(.bottom, 5)
                    
                    HStack {
                        Text("Format")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.standardFontBold(size: 18.0, relativeTo: .subheadline))
                            .padding(.bottom, 10)
                        Spacer()
                    }
                    
                    VStack(alignment: .leading) {
                        EditableLabel($vm.formatStr, containingWindow: (NSApplication.shared.delegate as! AppDelegate).copyFormatWindow, onEditEnd: {
                            vm.saveFormat()
                        })
                        .padding(5)
                    }
                    .frame(minWidth: 520)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(.gray, lineWidth: 1.5)
                    )
                }
                .fixedSize()
                
                VStack {
                    Text("Format Settings")
                        .font(.standardFontBold(size: 18, relativeTo: .subheadline))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 25)
                    
                    Divider()
                    
                    self.deleteField()
                }
                .padding([.leading, .trailing], 40)
            }
        }
        .frame(width: 600, height: 500)
        .padding()
        .background(.background)
    }
    
    @ViewBuilder func deleteField() -> some View {
        ResponseField(vm: ResponseFieldViewModel(content: ResponseFieldContent(
            title: "Delete Current Format",
            subtitle: "Removes the current format from saved formats",
            type: .action
        ), action: ResponseFieldAction(name: "Delete", destructive: true, dur: 2, onAction: {
            vm.removeCurrentFormat()
        })))
    }
}
