//
//  ReadFrameModifier.swift
//  OnePalette
//
//  Created by Joe Manto on 4/2/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import SwiftUI

private struct ReadFrameModifier: ViewModifier {
    
    @Binding var frame: CGRect
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear 
                        .onAppear {
                            frame = proxy.frame(in: CoordinateSpace.global)
                        }
                }
            )
    }
}

extension View {
    func readFrame(_ frame: Binding<CGRect>) -> some View {
        return self.modifier(ReadFrameModifier(frame: frame))
    }
}
