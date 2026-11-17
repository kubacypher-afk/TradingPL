import SwiftUI
import UIKit

// MARK: - TradingPL Brand Logo Component
struct TradingPLLogoView: View {
    var size: CGFloat = 140
    var showGlow: Bool = true
    
    var body: some View {
        ZStack {
            if showGlow {
                // Multi-tier ambient radial bloom
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "#FF7A00").opacity(0.55),
                                Color(hex: "#F0B90B").opacity(0.25),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: size * 0.15,
                            endRadius: size * 0.95
                        )
                    )
                    .frame(width: size * 1.8, height: size * 1.8)
                    .blur(radius: 20)
            }
            
            if let uiImage = loadLogoImage() {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                    .frame(width: size, height: size)
                    .overlay(
                        // Dual metallic rim
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "#FF9800"),
                                        Color(hex: "#F0B90B"),
                                        Color(hex: "#FF5722"),
                                        Color(hex: "#2B313A")
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3.5
                            )
                    )
                    .shadow(color: Color(hex: "#FF7A00").opacity(0.7), radius: 24, x: 0, y: 4)
            } else {
                // High-fidelity vector fallback matching logo geometry
                ZStack {
                    Circle()
                        .fill(Color(hex: "#1E2329"))
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "#FF7A00"), Color(hex: "#F0B90B")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3.5
                        )
                    
                    VStack(spacing: 2) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: size * 0.4, weight: .black))
                            .foregroundColor(Color(hex: "#FF7A00"))
                        Text("TP")
                            .font(.system(size: size * 0.24, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .frame(width: size, height: size)
                .shadow(color: Color(hex: "#FF7A00").opacity(0.6), radius: 20)
            }
        }
    }
    
    private func loadLogoImage() -> UIImage? {
        // 1. Try bundle path
        if let path = Bundle.main.path(forResource: "logo", ofType: "jpg"),
           let img = UIImage(contentsOfFile: path) {
            return img
        }
        // 2. Try bundle URL
        if let url = Bundle.main.url(forResource: "logo", withExtension: "jpg"),
           let data = try? Data(contentsOf: url),
           let img = UIImage(data: data) {
            return img
        }
        // 3. Try UIImage(named:)
        if let img = UIImage(named: "logo.jpg") ?? UIImage(named: "logo") {
            return img
        }
        // 4. Try bundle root directory
        let directUrl = Bundle.main.bundleURL.appendingPathComponent("logo.jpg")
        if let data = try? Data(contentsOf: directUrl),
           let img = UIImage(data: data) {
            return img
        }
        return nil
    }
}

// MARK: - TradingPL Cinematic Brand Splash View
struct BrandSplashView: View {
    let onFinished: () -> Void
    
    // Animation states
    @State private var logoScale: CGFloat = 0.25
    @State private var logoOpacity: Double = 0.0
    @State private var ringRotation1: Double = 0
    @State private var ringRotation2: Double = 360
    @State private var textOffset: CGFloat = 30
    @State private var textOpacity: Double = 0.0
    @State private var accentLineWidth: CGFloat = 0
    @State private var auraBreathing: Bool = false
    @State private var particlesAppeared: Bool = false
    
    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            
            ZStack {
                // Background deep obsidian void
                Color.binanceBg
                    .ignoresSafeArea()
                
                // MARK: - 1. Ambient Lighting & Glow Flares
                RadialGradient(
                    colors: [
                        Color(hex: "#FF7A00").opacity(0.25),
                        Color(hex: "#F0B90B").opacity(0.08),
                        Color(hex: "#181A20").opacity(0.95),
                        Color.binanceBg
                    ],
                    center: .center,
                    startRadius: 20,
                    endRadius: min(w, h) * 0.9
                )
                .ignoresSafeArea()
                
                // Floating subtle ambient light dust
                ForEach(0..<14, id: \.self) { i in
                    Circle()
                        .fill(i % 2 == 0 ? Color(hex: "#FF7A00").opacity(0.3) : Color(hex: "#F0B90B").opacity(0.25))
                        .frame(width: CGFloat((i % 4) + 3), height: CGFloat((i % 4) + 3))
                        .position(
                            x: w * (0.15 + 0.7 * CGFloat((i * 17) % 100) / 100.0),
                            y: h * (0.2 + 0.6 * CGFloat((i * 29) % 100) / 100.0) + (particlesAppeared ? -18 : 18)
                        )
                        .blur(radius: 1)
                        .opacity(particlesAppeared ? 0.7 : 0.0)
                        .animation(
                            .easeInOut(duration: Double(2.5 + Double(i % 3)))
                            .repeatForever(autoreverses: true),
                            value: particlesAppeared
                        )
                }
                
                // MARK: - 2. Orbital Gyroscope Light Rings (around Logo)
                ZStack {
                    // Outer dashed orbital ring (clockwise)
                    Circle()
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#FF7A00").opacity(0.8),
                                    Color(hex: "#F0B90B").opacity(0.2),
                                    Color.clear,
                                    Color(hex: "#FF7A00").opacity(0.5)
                                ]),
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [8, 6])
                        )
                        .frame(width: 220, height: 220)
                        .rotationEffect(.degrees(ringRotation1))
                    
                    // Inner satellite ring (counter-clockwise)
                    Circle()
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [
                                    Color.clear,
                                    Color(hex: "#F0B90B").opacity(0.7),
                                    Color.clear,
                                    Color(hex: "#FF9800").opacity(0.4)
                                ]),
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 1.2, lineCap: .round, dash: [4, 4])
                        )
                        .frame(width: 180, height: 180)
                        .rotationEffect(.degrees(ringRotation2))
                }
                .opacity(logoOpacity > 0.5 ? 1.0 : 0.0)
                
                // MARK: - 3. Central Brand Hero (Logo + TradingPL)
                VStack(spacing: 30) {
                    // Official Logo with Breathing Aura
                    TradingPLLogoView(size: 140, showGlow: true)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                        .scaleEffect(auraBreathing ? 1.03 : 0.98)
                    
                    // Brand Name "TradingPL" + Glowing Tapered Line
                    VStack(spacing: 14) {
                        Text("TradingPL")
                            .font(.system(size: 44, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color.white,
                                        Color(hex: "#FFFFFF"),
                                        Color(hex: "#E0E3E8")
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .tracking(3.5)
                            .shadow(color: Color(hex: "#FF7A00").opacity(0.55), radius: 18, x: 0, y: 4)
                            .shadow(color: Color.black.opacity(0.8), radius: 12, x: 0, y: 6)
                        
                        // Sleek glowing horizontal accent divider
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.clear,
                                        Color(hex: "#FF7A00"),
                                        Color(hex: "#F0B90B"),
                                        Color(hex: "#FF7A00"),
                                        Color.clear
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: accentLineWidth, height: 2.5)
                            .shadow(color: Color(hex: "#FF7A00").opacity(0.8), radius: 6)
                    }
                    .offset(y: textOffset)
                    .opacity(textOpacity)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // Tap anytime to fast-forward
            HapticsManager.shared.lightImpact()
            finish()
        }
        .onAppear {
            startCinematicSequence()
        }
    }
    
    // MARK: - Cinematic Sequence
    private func startCinematicSequence() {
        // Continuous orbital rotation
        withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
            ringRotation1 = 360
            ringRotation2 = 0
        }
        
        // Particles fade in
        particlesAppeared = true
        
        // 1. Logo explodes into focus with spring
        withAnimation(.spring(response: 0.65, dampingFraction: 0.66)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        HapticsManager.shared.rigidImpact()
        
        // 2. Text "TradingPL" slides up with high-impact haptic
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.74)) {
                textOffset = 0
                textOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.6)) {
                accentLineWidth = 130
            }
            HapticsManager.shared.notifySuccess()
        }
        
        // 3. Gentle breathing aura
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                auraBreathing = true
            }
        }
        
        // 4. Auto advance to Login / Register after 2.3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
            finish()
        }
    }
    
    private func finish() {
        withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
            onFinished()
        }
    }
}
