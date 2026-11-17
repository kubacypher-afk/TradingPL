import SwiftUI

// MARK: - App Navigation Stage
enum AppIntroStage {
    case cityMap
    case brandSplash
    case completed
}

// MARK: - Main Application Entry Point
@main
struct BinanceRadarApp: App {
    @StateObject private var viewModel = AuthViewModel()
    @State private var introStage: AppIntroStage = .cityMap
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                Color.binanceBg
                    .ignoresSafeArea()
                
                switch introStage {
                case .cityMap:
                    // Stage 1: Advanced 3D Crypto City Map & Connection Lasers
                    CryptoCityMapView(onFinished: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            introStage = .brandSplash
                        }
                    })
                    .transition(
                        .asymmetric(
                            insertion: .opacity,
                            removal: .scale(scale: 1.15).combined(with: .opacity)
                        )
                    )
                    
                case .brandSplash:
                    // Stage 2: Central TradingPL Logo + "TradingPL" Brand Animation
                    BrandSplashView(onFinished: {
                        withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
                            introStage = .completed
                        }
                    })
                    .transition(
                        .asymmetric(
                            insertion: .scale(scale: 0.85).combined(with: .opacity),
                            removal: .scale(scale: 1.1).combined(with: .opacity)
                        )
                    )
                    
                case .completed:
                    if viewModel.isAuthenticated {
                        // Stage 4: Binance Pro Main Trading Dashboard (120 FPS Spring Landing)
                        DashboardView(viewModel: viewModel)
                            .transition(
                                .asymmetric(
                                    insertion: .scale(scale: 0.92, anchor: .center).combined(with: .opacity),
                                    removal: .scale(scale: 1.05).combined(with: .opacity)
                                )
                            )
                    } else {
                        // Stage 3: Binance Master Authentication (Face ID + Login/Register)
                        AuthView(viewModel: viewModel)
                            .transition(
                                .asymmetric(
                                    insertion: .scale(scale: 0.95).combined(with: .opacity),
                                    removal: .scale(scale: 0.95).combined(with: .opacity)
                                )
                            )
                    }
                }
            }
            .preferredColorScheme(.dark)
            .animation(.spring(response: 0.55, dampingFraction: 0.8), value: introStage)
            .animation(.spring(response: 0.5, dampingFraction: 0.78), value: viewModel.isAuthenticated)
        }
    }
}
