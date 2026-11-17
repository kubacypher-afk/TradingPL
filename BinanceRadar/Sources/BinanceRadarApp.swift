import SwiftUI

// MARK: - Main Application Entry Point
@main
struct BinanceRadarApp: App {
    @StateObject private var viewModel = AuthViewModel()
    @State private var introCompleted: Bool = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                Color.binanceBg
                    .ignoresSafeArea()
                
                if !introCompleted {
                    // Stage 1: Advanced Crypto City Map & Connection Mesh Animation
                    CryptoCityMapView(onFinished: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            introCompleted = true
                        }
                    })
                    .transition(
                        .asymmetric(
                            insertion: .opacity,
                            removal: .scale(scale: 1.15).combined(with: .opacity)
                        )
                    )
                } else if viewModel.isAuthenticated {
                    // Stage 3: Binance Main Trading Dashboard (120 FPS Spring Landing)
                    DashboardView(viewModel: viewModel)
                        .transition(
                            .asymmetric(
                                insertion: .scale(scale: 0.92, anchor: .center).combined(with: .opacity),
                                removal: .scale(scale: 1.05).combined(with: .opacity)
                            )
                        )
                } else {
                    // Stage 2: Binance Pro Login & Registration with Native Face ID
                    AuthView(viewModel: viewModel)
                        .transition(
                            .asymmetric(
                                insertion: .scale(scale: 0.95).combined(with: .opacity),
                                removal: .scale(scale: 0.95).combined(with: .opacity)
                            )
                        )
                }
            }
            .preferredColorScheme(.dark)
            .animation(.spring(response: 0.55, dampingFraction: 0.8), value: introCompleted)
            .animation(.spring(response: 0.5, dampingFraction: 0.78), value: viewModel.isAuthenticated)
        }
    }
}
