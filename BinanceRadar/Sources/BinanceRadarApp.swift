import SwiftUI

// MARK: - Main Application Entry Point
@main
struct BinanceRadarApp: App {
    @StateObject private var viewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                Color.binanceBg
                    .ignoresSafeArea()
                
                if viewModel.isAuthenticated {
                    DashboardView(viewModel: viewModel)
                        .transition(
                            .asymmetric(
                                insertion: .scale(scale: 0.92, anchor: .center).combined(with: .opacity),
                                removal: .scale(scale: 1.05).combined(with: .opacity)
                            )
                        )
                } else {
                    AuthView(viewModel: viewModel)
                        .transition(
                            .asymmetric(
                                insertion: .opacity,
                                removal: .scale(scale: 0.95).combined(with: .opacity)
                            )
                        )
                }
            }
            .preferredColorScheme(.dark)
            .animation(.spring(response: 0.5, dampingFraction: 0.78), value: viewModel.isAuthenticated)
        }
    }
}
