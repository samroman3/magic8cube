//
//  Magic8CubeView.swift
//  8cube
//
//  Created by Sam Roman on 5/22/24.
//

import SwiftUI
import Combine

struct Magic8CubeView: View {
    @StateObject private var particleManager = ParticleManager()
    @State private var selectedAnswerIndex: Int = 0
    @State private var isAnimating: Bool = false
    @State private var offset: CGFloat = 0
    @State private var showParticles: Bool = true
    @State private var answerOpacity: Double = 0.0
    @State private var shakeOffset: CGFloat = 0
    
    private let answers = [
        "No", "Not Likely", "Absolutely", "Definitely", "Yes", "Ask Again", "Maybe", "Try Later"
    ]
    
    private var answerCount: Int {
        answers.count
    }
    
    var body: some View {
        VStack {
            ZStack {
                createBackground()
                    .frame(width: 200, height: 200)
                    .shadow(radius: 10)
                    .offset(y: shakeOffset)
                
                createAnswerScrollView()
                    .frame(width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
//                    .animation(.bouncy,value: shakeOffset)
                    .offset(y: shakeOffset)
                
                if showParticles {
                    CustomParticleView()
                        .frame(width: 200, height: 200)
                        .transition(.opacity)
                        .environmentObject(particleManager)
                }
                
                Text(answers[selectedAnswerIndex])
                    .foregroundColor(.white)
                    .font(.custom("Helvetica-Bold", size: 35))
                    .opacity(answerOpacity)
                    .frame(width: 180, height: 50, alignment: .leading)
                    .padding(.leading, 10)
                    .animation(.easeInOut(duration: 0.4), value: answerOpacity)
                
                createButton()
                    .frame(width: 200, height: 200)
                    .clipped()
            }
            .onAppear {
                particleManager.createParticles()
                startAnimation()
            }
        }
    }
    
    private func createBackground() -> some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.clear)
            .background(
                RadialGradient(
                    gradient: Gradient(colors: [Color(hex: "27124F"), Color(hex: "361C7D")]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 100
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
            )
            .overlay(
                RadialGradient(
                    gradient: Gradient(colors: [Color.white.opacity(0.2), Color.clear]),
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: 50
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
            )
            .overlay(
                RadialGradient(
                    gradient: Gradient(colors: [Color.clear, Color.white.opacity(0.1)]),
                    center: .bottomTrailing,
                    startRadius: -50,
                    endRadius: 0
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
            )
    }
    
    private func createAnswerScrollView() -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(0..<answerCount * 10, id: \.self) { index in
                    Text(answers[index % answerCount])
                        .foregroundColor(.white)
                        .font(.custom("Helvetica-Bold", size: 35))
                        .frame(width: 180, height: 50, alignment: .leading)
                        .padding(.leading, 10)
                }
            }
            .opacity(0.5)
            .offset(y: offset)
            .animation(Animation.easeInOut(duration: 4).repeatCount(0, autoreverses: false))
        }
    }
    
    private func createButton() -> some View {
        VStack {
            Spacer()
            HStack {
                if !isAnimating {
                    Spacer()
                    Button(action: startAnimation) {
                        Image(systemName: "arrow.clockwise")
                            .font(.body)
                            .foregroundColor(.white)
                            .padding(15)
                            .background(Material.ultraThinMaterial.opacity(0.4))
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 0.2)
                            )
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    }
                    .padding(10)
                    .clipShape(Circle())
                    .animation(.easeInOut, value: isAnimating)
                }
            }
        }
    }
    
    private func startAnimation() {
        isAnimating = true
        showParticles = true
        answerOpacity = 0.0
        particleManager.resetParticles()
        shakeCube()

        offset = -CGFloat(selectedAnswerIndex * 50)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                selectedAnswerIndex = Int.random(in: 0..<answers.count)
                offset = -CGFloat((selectedAnswerIndex + answerCount * 5) * 50 - 75)
                // Delay before revealing the answer
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    answerOpacity = 1.0
                    isAnimating = false
                    particleManager.moveParticlesAwayFromTextCenter()
                }
            }
    }
    
    private func shakeCube() {
        let animation = Animation.easeInOut(duration: 0.1).repeatCount(10, autoreverses: true)
        withAnimation(animation) {
            shakeOffset = 10
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            shakeOffset = 0
        }
        particleManager.shakeParticles()
    }
}

struct Magic8CubeView_Previews: PreviewProvider {
    static var previews: some View {
        Magic8CubeView()
    }
}

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

struct Particle: Identifiable {
    let id = UUID()
    var size: CGFloat
    var lifetime: Double
    var position: CGPoint
    var initialPosition: CGPoint
    var opacity: Double
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
