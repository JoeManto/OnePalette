//
//  Shake.swift
//  OnePalette
//
//  Created by Joe Manto on 4/22/23.
//  Copyright © 2023 Joe Manto. All rights reserved.
//

import Foundation
import SwiftUI

enum ShakeIntensity: CGFloat {
    case none = 0.0
    case soft = 0.5
    case normal = 1
    case high = 1.5
}

private struct Shake: GeometryEffect {
    var distance: CGFloat = 8
    var numberOfShakes = 1
    var animatableData: CGFloat
    
    init(intensity: ShakeIntensity = .normal) {
        self.animatableData = intensity.rawValue
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = distance * sin(animatableData * .pi * 2)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

extension View {
    func shake(intensity: ShakeIntensity) -> some View {
        modifier(Shake(intensity: intensity))
    }
}
