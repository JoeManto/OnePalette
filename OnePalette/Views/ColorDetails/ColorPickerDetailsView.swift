//
//  ColorPickerDetailsView.swift
//  OnePalette
//
//  Created by Joe Manto on 6/15/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import SwiftUI

struct ColorPickerDetailsView: View {
    
    var body: some View {
        Text("Hello")
    }
}

struct ColorPickerDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ColorPickerDetailsView()
    }
}


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
}


