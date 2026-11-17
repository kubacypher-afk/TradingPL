import SwiftUI

// MARK: - Master Authentication Screen (Clean & High-Motion)
struct AuthView: View {
    @ObservedObject var viewModel: AuthViewModel
    @Namespace private var tabNamespace
    
    var body: some View {
        ZStack {
            // Background
            Color.binanceBg
                .ignoresSafeArea()
            
            // Subtle ambient lighting behind card
            RadialGradient(
                colors: [
                    Color(hex: "#FF7A00").opacity(0.12),
                    Color(hex: "#F0B90B").opacity(0.04),
                    Color.clear
                ],
                center: .top,
                startRadius: 20,
                endRadius: 360
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - 1. Top Header (Clean Minimalist Branding)
                HStack(spacing: 12) {
                    TradingPLLogoView(size: 36, showGlow: false)
                    
                    Text("TradingPL")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(.binanceTextPrimary)
                        .tracking(1.2)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 20)
                
                // MARK: - 2. Error Banner
                if let error = viewModel.errorMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.binanceRed)
                            .font(.system(size: 13))
                        Text(error)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.binanceRed)
                        Spacer()
                    }
                    .padding(12)
                    .background(Color.binanceRedBg)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.binanceRed.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // MARK: - 3. Success Banner
                if let success = viewModel.successBannerMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.binanceGreen)
                            .font(.system(size: 13))
                        Text(success)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.binanceGreen)
                        Spacer()
                    }
                    .padding(12)
                    .background(Color.binanceGreenBg)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.binanceGreen.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // MARK: - 4. Modern Floating Capsule Segment Switcher (120 FPS)
                HStack(spacing: 6) {
                    ForEach(AuthTab.allCases, id: \.self) { tab in
                        Button(action: {
                            HapticsManager.shared.lightImpact()
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                viewModel.selectedTab = tab
                                viewModel.errorMessage = nil
                            }
                        }) {
                            Text(tab.rawValue)
                                .font(.system(size: 14, weight: viewModel.selectedTab == tab ? .bold : .semibold))
                                .foregroundColor(viewModel.selectedTab == tab ? .binanceBg : .binanceTextSecondary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 40)
                                .background(
                                    ZStack {
                                        if viewModel.selectedTab == tab {
                                            Capsule()
                                                .fill(Color.binanceYellow)
                                                .matchedGeometryEffect(id: "activeTabCapsule", in: tabNamespace)
                                                .shadow(color: Color.binanceYellow.opacity(0.4), radius: 8, x: 0, y: 2)
                                        }
                                    }
                                )
                        }
                    }
                }
                .padding(4)
                .background(Color.binanceCard)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(Color.binanceBorder, lineWidth: 1)
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
                
                // MARK: - 5. Scrollable Form Body
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        if viewModel.selectedTab == .login {
                            LoginView(viewModel: viewModel)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .leading).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                        } else {
                            RegisterView(viewModel: viewModel)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .trailing).combined(with: .opacity)
                                ))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 4)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}
