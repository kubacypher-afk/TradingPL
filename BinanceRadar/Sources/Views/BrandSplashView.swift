import SwiftUI
import UIKit

// MARK: - TradingPL Brand Logo Component
struct TradingPLLogoView: View {
    var size: CGFloat = 110
    var showGlow: Bool = true
    
    var body: some View {
        ZStack {
            if showGlow {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "#FF7A00").opacity(0.45),
                                Color(hex: "#F0B90B").opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: size * 0.2,
                            endRadius: size * 0.8
                        )
                    )
                    .frame(width: size * 1.5, height: size * 1.5)
                    .blur(radius: 12)
            }
            
            if let uiImage = loadLogoImage() {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                    .frame(width: size, height: size)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "#FF7A00"),
                                        Color(hex: "#F0B90B"),
                                        Color(hex: "#2B313A")
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2.5
                            )
                    )
                    .shadow(color: Color(hex: "#FF7A00").opacity(0.6), radius: 16)
            } else {
                // High-fidelity fallback circle matching logo geometry
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
                            lineWidth: 3
                        )
                    
                    VStack(spacing: 2) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: size * 0.38, weight: .bold))
                            .foregroundColor(Color(hex: "#FF7A00"))
                        Text("TP")
                            .font(.system(size: size * 0.22, weight: .black))
                            .foregroundColor(.white)
                    }
                }
                .frame(width: size, height: size)
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

// MARK: - TradingPL Brand Splash View (Post-Map Animation)
struct BrandSplashView: View {
    let onFinished: () -> Void
    
    @State private var logoScale: CGFloat = 0.3
    @State private var logoOpacity: Double = 0.0
    @State private var textOffset: CGFloat = 24
    @State private var textOpacity: Double = 0.0
    @State private var auraPulse: Bool = false
    
    var body: some View {
        ZStack {
            Color.binanceBg
                .ignoresSafeArea()
            
            // Atmospheric Radial Gradient
            RadialGradient(
                colors: [
                    Color(hex: "#FF7A00").opacity(0.16),
                    Color(hex: "#181A20").opacity(0.9),
                    Color.binanceBg
                ],
                center: .center,
                startRadius: 20,
                endRadius: 400
            )
            .ignoresSafeArea()
            
            // Central Brand Card
            VStack(spacing: 26) {
                // Official TradingPL Logo with glowing aura
                TradingPLLogoView(size: 130, showGlow: true)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    .scaleEffect(auraPulse ? 1.04 : 0.98)
                
                // Brand Name "TradingPL"
                VStack(spacing: 10) {
                    Text("TradingPL")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color(hex: "#EAECEF")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .tracking(3.0)
                        .shadow(color: Color.black.opacity(0.6), radius: 10, x: 0, y: 4)
                    
                    HStack(spacing: 10) {
                        Rectangle()
                            .fill(Color(hex: "#FF7A00"))
                            .frame(width: 24, height: 2)
                        
                        Text("PRO CRYPTO TERMINAL")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(hex: "#F0B90B"))
                            .tracking(2.5)
                        
                        Rectangle()
                            .fill(Color(hex: "#FF7A00"))
                            .frame(width: 24, height: 2)
                    }
                }
                .offset(y: textOffset)
                .opacity(textOpacity)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // Tap to fast-forward straight to login/register
            HapticsManager.shared.lightImpact()
            finish()
        }
        .onAppear {
            startBrandSequence()
        }
    }
    
    private func startBrandSequence() {
        // Step 1: Pop logo into view with spring
        withAnimation(.spring(response: 0.65, dampingFraction: 0.68)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        HapticsManager.shared.rigidImpact()
        
        // Step 2: Slide up text "TradingPL"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                textOffset = 0
                textOpacity = 1.0
            }
            HapticsManager.shared.notifySuccess()
        }
        
        // Step 3: Gentle breathing aura pulse
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                auraPulse = true
            }
        }
        
        // Step 4: Advance to Login & Registration after 2.4s
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            finish()
        }
    }
    
    private func finish() {
        withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
            onFinished()
        }
    }
}
