import SwiftUI

// MARK: - Binance Registration View
struct RegisterView: View {
    @ObservedObject var viewModel: AuthViewModel
    
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
            
            // Confirm Password Input
            BinanceInputField(
                title: "Powtórz Hasło",
                placeholder: "Wprowadź ponownie hasło",
                systemImage: "lock.shield.fill",
                text: $viewModel.regConfirmPassword,
                isSecure: true
            )
            
            // Biometric Face ID Enrollment Toggle Card (Binance Style)
            Button(action: {
                HapticsManager.shared.lightImpact()
                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                    viewModel.enableBiometricsOnRegister.toggle()
                }
            }) {
                HStack(spacing: 12) {
                    // Biometric Icon Capsule
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(viewModel.enableBiometricsOnRegister ? Color.binanceYellow.opacity(0.15) : Color.binanceSurface)
                            .frame(width: 38, height: 38)
                        
                        Image(systemName: "faceid")
                            .font(.system(size: 20))
                            .foregroundColor(viewModel.enableBiometricsOnRegister ? .binanceYellow : .binanceTextSecondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Logowanie biometryczne (Face ID)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.binanceTextPrimary)
                        
                        Text("Skanuje twarz przy rejestracji i aktywuje logowanie jednym spojrzeniem.")
                            .font(.system(size: 11))
                            .foregroundColor(.binanceTextSecondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    // Custom Checkbox
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(viewModel.enableBiometricsOnRegister ? Color.binanceYellow : Color.binanceSurface)
                            .frame(width: 22, height: 22)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(viewModel.enableBiometricsOnRegister ? Color.binanceYellow : Color.binanceBorder, lineWidth: 1.5)
                            )
                        
                        if viewModel.enableBiometricsOnRegister {
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(.binanceBg)
                        }
                    }
                }
                .padding(12)
                .background(Color.binanceCard)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(viewModel.enableBiometricsOnRegister ? Color.binanceYellow.opacity(0.5) : Color.binanceBorder, lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Register CTA Button
            Button(action: {
                Task {
                    await viewModel.register()
                }
            }) {
                HStack(spacing: 8) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .binanceBg))
                    } else {
                        if viewModel.enableBiometricsOnRegister {
                            Image(systemName: "faceid")
                                .font(.system(size: 16, weight: .bold))
                        }
                        Text(viewModel.enableBiometricsOnRegister ? "Zarejestruj & Skanuj Face ID" : "Zarejestruj się")
                    }
                }
            }
            .buttonStyle(BinanceButtonStyle(isEnabled: !viewModel.isLoading))
            .disabled(viewModel.isLoading)
            .padding(.top, 4)
            
            // Terms Note
            Text("Rejestrując konto, akceptujesz Warunki Świadczenia Usług Binance Radar oraz zasady kryptografii Apple Secure Enclave.")
                .font(.system(size: 11))
                .foregroundColor(.binanceTextMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
                .padding(.top, 2)
        }
    }
}
