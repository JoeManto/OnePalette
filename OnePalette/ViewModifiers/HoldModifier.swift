//
//  HoldModifier.swift
//  OnePalette
//
//  Created by Joe Manto on 3/26/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import SwiftUI

fileprivate struct HoldModifier: ViewModifier {
    
    fileprivate let onTap: (() -> ())?
    fileprivate let onRelease: ((Double) -> ())?
    
    @State private var tapTime = Date()
    @State private var pressing = false
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ _ in
                        if pressing == false {
                            pressing = true
                            tapTime = Date()
                            self.onTap?()
                        }
                    })
                    .onEnded({ _ in
                        pressing = false
                        self.onRelease?(tapTime.distance(to: Date.now))
                    })
                )
    }
}

extension View {
    func onHold(onTap: (() -> ())? = nil, onRelease: ((Double) -> ())? = nil) -> some View {
        return self.modifier(HoldModifier(onTap: onTap, onRelease: onRelease))
    }
}
