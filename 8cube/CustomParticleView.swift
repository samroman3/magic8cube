//
//  CustomParticleView.swift
//  8cube
//
//  Created by Sam Roman on 5/23/24.
//

import SwiftUI
struct CustomParticleView: View {
    @EnvironmentObject var particleManager: ParticleManager
    
    var body: some View {
        ZStack {
            ForEach(particleManager.particles) { particle in
                Circle()
                    .fill(Color.white.opacity(particle.opacity))
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .animation(Animation.linear(duration: particle.lifetime).repeatCount(1, autoreverses: false))
            }
        }
        .mask(
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 200, height: 200)
        )
    }
}
