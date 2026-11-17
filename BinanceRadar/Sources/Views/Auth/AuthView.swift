import SwiftUI

// MARK: - Binance Master Authentication Screen
struct AuthView: View {
    @ObservedObject var viewModel: AuthViewModel
    @Namespace private var tabNamespace
    
    var body: some View {
        ZStack {
            // Background
            Color.binanceBg
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Top Header (Binance Status & Logo)
                HStack(spacing: 12) {
                    BinanceDiamondLogo(size: 28, color: .binanceYellow)
                    
                    VStack(alignment: .leading, spacing: 1) {
                        HStack(spacing: 4) {
                            Text("BINANCE")
                                .font(.system(size: 15, weight: .black, design: .rounded))
                                .foregroundColor(.binanceTextPrimary)
                            Text("RADAR")
                                .font(.system(size: 15, weight: .black, design: .rounded))
                                .foregroundColor(.binanceYellow)
                        }
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.binanceGreen)
                                .frame(width: 5, height: 5)
                            Text("ENGINE 24/7 ONLINE")
                                .font(.system(size: 8, weight: .bold, design: .monospaced))
                                .foregroundColor(.binanceGreen)
                        }
                    }
                    
                    Spacer()
                    
                    // Network / Passkey Badge
                    HStack(spacing: 4) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 11))
                        Text("PASSKEY")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(.binanceYellow)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.binanceYellow.opacity(0.12))
                    .cornerRadius(6)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 16)
                
                // MARK: - Error Banner (if any)
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
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.binanceRed.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // MARK: - Success Banner (e.g. after Registration)
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
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.binanceGreen.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // MARK: - Binance Pro Tab Bar (Sliding Indicator)
                HStack(spacing: 0) {
                    ForEach(AuthTab.allCases, id: \.self) { tab in
                        Button(action: {
                            HapticsManager.shared.lightImpact()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) {
                                viewModel.selectedTab = tab
                                viewModel.errorMessage = nil
                            }
                        }) {
                            VStack(spacing: 8) {
                                Text(tab.rawValue)
                                    .font(.system(size: 15, weight: viewModel.selectedTab == tab ? .bold : .medium))
                                    .foregroundColor(viewModel.selectedTab == tab ? .binanceTextPrimary : .binanceTextSecondary)
                                    .frame(maxWidth: .infinity)
                                
                                // Sliding Yellow Bar
                                ZStack {
                                    if viewModel.selectedTab == tab {
                                        Rectangle()
                                            .fill(Color.binanceYellow)
                                            .frame(height: 2.5)
                                            .matchedGeometryEffect(id: "activeTabLine", in: tabNamespace)
                                            .shadow(color: Color.binanceYellow.opacity(0.5), radius: 4, x: 0, y: 1)
                                    } else {
                                        Rectangle()
                                            .fill(Color.clear)
                                            .frame(height: 2.5)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .overlay(
                    Rectangle()
                        .fill(Color.binanceBorder)
                        .frame(height: 1),
                    alignment: .bottom
                )
                
                // MARK: - Scrollable Form Body
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
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 36)
                }
            }
        }
    }
}
