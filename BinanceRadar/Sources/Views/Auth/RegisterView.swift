import SwiftUI

// MARK: - Registration View (Clean & High-Motion)
struct RegisterView: View {
    @ObservedObject var viewModel: AuthViewModel
    
    // Computed password matching status
    private var passwordsMatch: Bool {
        !viewModel.regPassword.isEmpty && viewModel.regPassword == viewModel.regConfirmPassword
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // E-mail Input
            BinanceInputField(
                title: "Adres E-mail",
                placeholder: "twoj.email@domena.com",
                systemImage: "envelope.fill",
                text: $viewModel.regEmail,
                keyboardType: .emailAddress
            )
            
            // Phone Number Input
            BinanceInputField(
                title: "Numer Telefonu",
                placeholder: "123 456 789",
                systemImage: "phone.fill",
                text: $viewModel.regPhone,
                keyboardType: .phonePad,
                prefix: "+48"
            )
            
            // Password Input
            BinanceInputField(
                title: "Hasło",
                placeholder: "Wprowadź hasło (min. 6 znaków)",
                systemImage: "lock.fill",
                text: $viewModel.regPassword,
                isSecure: true
            )
            
            // Confirm Password Input with Match Indicator
            VStack(alignment: .trailing, spacing: 6) {
                BinanceInputField(
                    title: "Powtórz Hasło",
                    placeholder: "Wprowadź ponownie hasło",
                    systemImage: "lock.shield.fill",
                    text: $viewModel.regConfirmPassword,
                    isSecure: true
                )
                
                // Real-time Match Indicator
                if !viewModel.regConfirmPassword.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: passwordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.system(size: 11))
                        Text(passwordsMatch ? "Hasła są identyczne" : "Hasła nie są identyczne")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(passwordsMatch ? .binanceGreen : .binanceRed)
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }
            }
            
            // MARK: - Biometric Face ID Enrollment Card
            Button(action: {
                HapticsManager.shared.lightImpact()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) {
                    viewModel.enableBiometricsOnRegister.toggle()
                }
            }) {
                HStack(spacing: 14) {
                    // Biometric Icon Capsule
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(viewModel.enableBiometricsOnRegister ? Color.binanceYellow.opacity(0.18) : Color.binanceSurface)
                            .frame(width: 42, height: 42)
                        
                        Image(systemName: "faceid")
                            .font(.system(size: 22))
                            .foregroundColor(viewModel.enableBiometricsOnRegister ? .binanceYellow : .binanceTextSecondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Logowanie biometryczne (Face ID)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.binanceTextPrimary)
                        
                        Text("Skanuje twarz przy rejestracji i aktywuje szybkie logowanie")
                            .font(.system(size: 11))
                            .foregroundColor(.binanceTextSecondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    // Custom Toggle Pill Switch
                    ZStack(alignment: viewModel.enableBiometricsOnRegister ? .trailing : .leading) {
                        Capsule()
                            .fill(viewModel.enableBiometricsOnRegister ? Color.binanceYellow : Color.binanceBorder)
                            .frame(width: 44, height: 26)
                        
                        Circle()
                            .fill(viewModel.enableBiometricsOnRegister ? Color.binanceBg : Color.binanceTextSecondary)
                            .frame(width: 20, height: 20)
                            .padding(.horizontal, 3)
                            .shadow(radius: 2)
                    }
                    .animation(.spring(response: 0.25, dampingFraction: 0.7), value: viewModel.enableBiometricsOnRegister)
                }
                .padding(14)
                .background(Color.binanceCard)
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(viewModel.enableBiometricsOnRegister ? Color.binanceYellow.opacity(0.5) : Color.binanceBorder, lineWidth: 1.2)
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // MARK: - Register Primary Button
            Button(action: {
                HapticsManager.shared.mediumImpact()
                Task {
                    await viewModel.register()
                }
            }) {
                HStack(spacing: 10) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .binanceBg))
                            .scaleEffect(0.9)
                    } else {
                        if viewModel.enableBiometricsOnRegister {
                            Image(systemName: "faceid")
                                .font(.system(size: 16, weight: .bold))
                            Text("Zarejestruj i skanuj Face ID")
                                .font(.system(size: 15, weight: .bold))
                        } else {
                            Text("Utwórz konto")
                                .font(.system(size: 15, weight: .bold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 13, weight: .bold))
                        }
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
