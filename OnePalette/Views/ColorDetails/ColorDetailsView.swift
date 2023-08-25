//
//  ColorPickerDetailsView.swift
//  OnePalette
//
//  Created by Joe Manto on 6/15/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import SwiftUI
import AppSDK

struct ColorDetailsView: View {
    
    @ObservedObject var vm: ColorDetailsViewModel
        
    var body: some View {
        VStack {
            EditableLabel($vm.hexStringTextValue, containingWindow: vm.window, onEditEnd: {
                vm.onHexTextEditEnd()
            })
            
            brightnessControl()
            saturationControl()
            Spacer()
        }
    }
    
    @ViewBuilder func brightnessControl() -> some View {
        VStack {
            HStack {
                Text("Brightness")
                    .foregroundStyle(Color(NSColor.lightGray))
                    .bold()
                
                Spacer()
            }
            HStack {
                EditableLabel($vm.brightnessTextValue, containingWindow: vm.window, onEditEnd: {
                    
                })
                .overlay(content: {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color(NSColor.darkGray), lineWidth: 1)
                })
                .frame(minWidth: 30, maxWidth: 30)
                
                Spacer()
                
                ColorComponentSlider(initalValue: 1.0, percentage: $vm.brightnessSliderValue)
            }
        }
        .padding(5)
    }
    
    @ViewBuilder func saturationControl() -> some View {
        VStack {
            HStack {
                Text("Saturation")
                    .foregroundStyle(Color(NSColor.lightGray))
                    .bold()
                Spacer()
            }
            HStack {
                EditableLabel($vm.saturationTextValue, containingWindow: vm.window, onEditEnd: {
                    
                })
                .overlay(content: {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color(NSColor.darkGray), lineWidth: 1)
                })
                .frame(minWidth: 30, maxWidth: 30)
                
                Spacer()
                
                ColorComponentSlider(initalValue: 1.0, percentage: $vm.saturationSliderValue)
            }
        }
        .padding(5)
    }
}

/*
struct ColorOptionSelector: View {
    
    let options = ["HSV", "Components"]
        
    @State var frame1: CGRect = .zero
    @State var frame2: CGRect = .zero
    
    @State var selectedFrame: CGRect = .zero
    
    var animationData: Int = 0
    
    var body: some View {
        ZStack {
            Color.green
                //.offset(x: selectedFrame.origin.x, y: selectedFrame.origin.y)
                //.position(x: selectedFrame.origin.x, y: selectedFrame.origin.y)
                //.pos
                //.frame(width: selectedFrame.width, height: selectedFrame.height)
                //.animation(/*@START_MENU_TOKEN@*/.easeIn/*@END_MENU_TOKEN@*/)
            
            HStack {
                Text("HSV")
                    .readFrame($frame1)
                
                Text("Components")
                    .readFrame($frame2)
                    .onTapGesture {
                        selectedFrame = frame2
                    }
            }
            //.padding(5)
            

        }

    }
}*/
