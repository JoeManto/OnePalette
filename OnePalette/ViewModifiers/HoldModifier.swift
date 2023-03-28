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
    fileprivate let maxHoldTime: Int?
    
    @State private var tapTime = Date()
    @State private var pressing = false
    
    private func release() {
        guard self.pressing else {
            // If the user is no longer pressing the release block was already called
            return
        }
        
        self.pressing = false
        self.onRelease?(tapTime.distance(to: Date.now))
    }
    
    private func tap() {
        guard self.pressing == false else {
            return
        }
        
        self.pressing = true
        self.tapTime = Date()
        self.onTap?()
        
        if let max = maxHoldTime {
            DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(max))) {
                self.release()
            }
        }
    }
    
    func body(content: Content) -> some View {
        content.simultaneousGesture(DragGesture(minimumDistance: 0)
            .onChanged({ _ in
                self.tap()
            })
            .onEnded({ _ in
                self.release()
            })
        )
    }
}

extension View {
    func onHold(onTap: (() -> ())? = nil, onRelease: ((Double) -> ())? = nil, maxHoldTime: Int? = nil) -> some View {
        return self.modifier(HoldModifier(onTap: onTap, onRelease: onRelease, maxHoldTime: maxHoldTime))
    }
}
