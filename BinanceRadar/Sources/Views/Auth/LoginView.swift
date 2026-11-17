import SwiftUI

// MARK: - Binance Login View
struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var isPulsing: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            // MARK: - 1. Dedykowany Przycisk Logowania Biometrycznego (Face ID)
            VStack(spacing: 10) {
                Button(action: {
                    Task {
                        await viewModel.loginWithBiometrics()
                    }
                }) {
                    HStack(spacing: 14) {
                        // Animated Biometric Icon
                        ZStack {
                            Circle()
                                .fill(Color.binanceYellow.opacity(0.18))
                                .frame(width: 44, height: 44)
                                .scaleEffect(isPulsing ? 1.15 : 1.0)
                                .opacity(isPulsing ? 0.7 : 1.0)
                            
                            Image(systemName: "faceid")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.binanceYellow)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Loguj za pomocą Face ID")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.binanceTextPrimary)
                            
                            Text("Apple Secure Enclave Passkey")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.binanceYellow)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.binanceTextSecondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.binanceCard)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.binanceYellow.opacity(0.55), lineWidth: 1.5)
                    )
                    .shadow(color: Color.binanceYellow.opacity(0.15), radius: 10, x: 0, y: 4)
                }
                .buttonStyle(PlainButtonStyle())
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                        isPulsing = true
                    }
                }
            }
            
            // MARK: - Divider: LUB PRZEZ NUMER TELEFONU I HASŁO
            HStack(spacing: 12) {
                Rectangle()
                    .fill(Color.binanceBorder)
                    .frame(height: 1)
                
                Text("LUB NR TELEFONU I HASŁO")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.binanceTextMuted)
                    .textCase(.uppercase)
                
                Rectangle()
                    .fill(Color.binanceBorder)
                    .frame(height: 1)
            }
            .padding(.vertical, 4)
            
            // MARK: - 2. Logowanie tradycyjne (Nr Telefonu / E-mail + Hasło)
            VStack(spacing: 14) {
                // Phone or Email Input
                BinanceInputField(
                    title: "Numer Telefonu / E-mail",
                    placeholder: "Wprowadź numer lub e-mail",
                    systemImage: "person.fill",
                    text: $viewModel.loginPhoneOrEmail,
                    keyboardType: .default
                )
                
                // Password Input
                BinanceInputField(
                    title: "Hasło",
                    placeholder: "Wprowadź hasło",
                    systemImage: "lock.fill",
                    text: $viewModel.loginPassword,
                    isSecure: true
                )
                
                // Forgot Password link
                HStack {
                    Spacer()
                    Button("Nie pamiętasz hasła?") {
                        HapticsManager.shared.lightImpact()
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.binanceYellow)
                }
                .padding(.top, -4)
                
                // Login Submit Button (Binance Yellow)
                Button(action: {
                    viewModel.loginWithPassword()
                }) {
                    HStack(spacing: 8) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .binanceBg))
                        } else {
                            Text("Zaloguj się")
                        }
                    }
                }
                .buttonStyle(BinanceButtonStyle(isEnabled: !viewModel.isLoading))
                .disabled(viewModel.isLoading)
                .padding(.top, 4)
            }
        }
    }
}
