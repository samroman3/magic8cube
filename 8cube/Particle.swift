//
//  Particle.swift
//  8cube
//
//  Created by Sam Roman on 5/23/24.
//

import Foundation
struct Particle: Identifiable {
    let id = UUID()
    var size: CGFloat
    var lifetime: Double
    var position: CGPoint
    var initialPosition: CGPoint
    var opacity: Double
}
