//
//  ContentView.swift
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
    
    private func playStartSounds(){
        SoundManager.shared.playSoundsSequentially(with: [(wavFileName: "musical-tap-3", ahapFileName: "musical-tap-3", interval: 1),(wavFileName: "atmosphere-1", ahapFileName: "atmosphere-1", interval: 1)])
    }
    
    private func playWhoosh(){
        SoundManager.shared.playSound(wavFileName: "whoosh-2", ahapFileName: "whoosh-2")
    }
    
    
    
    private func startAnimation() {
        isAnimating = true
        showParticles = true
        answerOpacity = 0.0
        particleManager.resetParticles()
        shakeCube()
        playStartSounds()

        offset = -CGFloat(selectedAnswerIndex * 50)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                selectedAnswerIndex = Int.random(in: 0..<answers.count)
                offset = -CGFloat((selectedAnswerIndex + answerCount * 5) * 50 - 75)
                // Delay before revealing the answer
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    answerOpacity = 1.0
                    isAnimating = false
                    particleManager.moveParticlesAwayFromTextCenter()
                    playWhoosh()
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

