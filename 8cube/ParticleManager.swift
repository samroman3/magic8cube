//
//  ParticleManager.swift
//  8cube
//
//  Created by Sam Roman on 5/23/24.
//

import SwiftUI
class ParticleManager: ObservableObject {
    @Published var particles = [Particle]()

    init() {
        createParticles()
    }

    func createParticles(sizeRange: ClosedRange<CGFloat> = 0.2...0.9, lifetimeRange: ClosedRange<Double> = 1...2, ensureDistanceFromTextCenter: Bool = false) {
        particles.removeAll()
        for _ in 0..<2000 {
            let size = CGFloat.random(in: sizeRange)
            let lifetime = Double.random(in: lifetimeRange)
            var position: CGPoint

            repeat {
                position = CGPoint(x: CGFloat.random(in: 0...200), y: CGFloat.random(in: 0...200))
            } while ensureDistanceFromTextCenter && distanceToTextCenter(position) < 40 // Ensure fewer particles near the text center if needed

            let opacity = Double.random(in: 0.5...1.0)
            let particle = Particle(size: size, lifetime: lifetime, position: position, initialPosition: position, opacity: opacity)

            particles.append(particle)
        }
    }

    func moveParticlesAwayFromTextCenter() {
        for index in particles.indices {
            let newPosition = calculateNewPosition(for: particles[index].initialPosition)
            particles[index].position = newPosition
            particles[index].lifetime = Double.random(in: 1...2)
        }
    }

    func resetParticles() {
        for index in particles.indices {
            particles[index].position = particles[index].initialPosition
            particles[index].opacity = Double.random(in: 0.1...1.0)
        }
    }

    func shakeParticles() {
        for index in particles.indices {
            particles[index].position.x += CGFloat.random(in: -10...10)
            particles[index].position.y += CGFloat.random(in: -10...10)
        }
    }

    private func calculateNewPosition(for position: CGPoint) -> CGPoint {
        let textCenter = CGPoint(x: 70, y: 100) // Adjusted for text alignment
        let dx = position.x - textCenter.x
        let dy = position.y - textCenter.y
        let scaleFactor = CGFloat.random(in: 1.5...2.5)
        let newX = textCenter.x + dx * scaleFactor
        let newY = textCenter.y + dy * scaleFactor
        let spreadX = dx > 0 ? CGFloat.random(in: 1.0...1.5) : CGFloat.random(in: 0.5...1.0)
        let spreadY = dy > 0 ? CGFloat.random(in: 1.0...1.5) : CGFloat.random(in: 0.5...1.0)
        return CGPoint(x: max(-20, min(220, newX * spreadX)), y: max(-20, min(220, newY * spreadY))) // Ensure particles stay within bounds
    }

    private func distanceToTextCenter(_ position: CGPoint) -> CGFloat {
        let textCenter = CGPoint(x: 70, y: 100) // Adjusted for text alignment
        let dx = position.x - textCenter.x
        let dy = position.y - textCenter.y
        return sqrt(dx * dx + dy * dy)
    }
}
