import SwiftUI

// MARK: - Login View (Clean & High-Motion)
struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var isPulsing: Bool = false
    @State private var shimmerOffset: CGFloat = -180
    
    var body: some View {
        VStack(spacing: 22) {
            // MARK: - 1. Hero Face ID Biometric Card
            Button(action: {
                HapticsManager.shared.mediumImpact()
                Task {
                    await viewModel.loginWithBiometrics()
                }
            }) {
                ZStack {
                    // Card Background
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.binanceCard,
                                    Color(hex: "#22272E")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Animated Shimmer Light Sweep
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.binanceYellow.opacity(0.12),
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(x: shimmerOffset)
                    
                    // Card Border with Yellow Accent
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.binanceYellow.opacity(0.7),
                                    Color(hex: "#FF7A00").opacity(0.4),
                                    Color.binanceBorder
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                    
                    // Content
                    HStack(spacing: 16) {
                        // Pulsing Biometric Icon
                        ZStack {
                            Circle()
                                .stroke(Color.binanceYellow.opacity(0.3), lineWidth: 1.5)
                                .frame(width: 48, height: 48)
                                .scaleEffect(isPulsing ? 1.25 : 1.0)
                                .opacity(isPulsing ? 0.0 : 0.8)
                            
                            Circle()
                                .fill(Color.binanceYellow.opacity(0.15))
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: "faceid")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.binanceYellow)
                        }
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Loguj za pomocą Face ID")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.binanceTextPrimary)
                            
                            Text("Dotknij, aby zeskanować twarz")
                                .font(.system(size: 12))
                                .foregroundColor(.binanceTextSecondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.binanceYellow)
                            .padding(.trailing, 4)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 16)
                }
                .frame(height: 76)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.binanceYellow.opacity(0.12), radius: 12, x: 0, y: 4)
            }
            .buttonStyle(ScaleButtonStyle())
            .onAppear {
                withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
                withAnimation(.linear(duration: 2.8).repeatForever(autoreverses: false)) {
                    shimmerOffset = 220
                }
            }
            
            // MARK: - 2. Clean Minimalist Divider
            HStack(spacing: 14) {
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
            .padding(.vertical, 2)
            
            // MARK: - 3. Traditional Form Inputs
            VStack(spacing: 16) {
                BinanceInputField(
                    title: "Numer Telefonu / E-mail",
                    placeholder: "Wprowadź numer lub e-mail",
                    systemImage: "person.fill",
                    text: $viewModel.loginPhoneOrEmail,
                    keyboardType: .default
                )
                
                BinanceInputField(
                    title: "Hasło",
                    placeholder: "Wprowadź hasło",
                    systemImage: "lock.fill",
                    text: $viewModel.loginPassword,
                    isSecure: true
                )
            }
            
            // MARK: - 4. Primary Login Button
            Button(action: {
                HapticsManager.shared.mediumImpact()
                viewModel.loginWithPassword()
            }) {
                HStack(spacing: 8) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .binanceBg))
                            .scaleEffect(0.9)
                    } else {
                        Text("Zaloguj się")
                            .font(.system(size: 15, weight: .bold))
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 13, weight: .bold))
                    }
                }
                .foregroundColor(.binanceBg)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        colors: [Color.binanceYellowButton, Color.binanceYellow],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(12)
                .shadow(color: Color.binanceYellow.opacity(0.35), radius: 10, x: 0, y: 4)
            }
            .disabled(viewModel.isLoading)
            .buttonStyle(ScaleButtonStyle())
            .padding(.top, 4)
        }
    }
}
