import SwiftUI

// MARK: - Binance Styled Clean Input Field
struct BinanceInputField: View {
    let title: String
    let placeholder: String
    let systemImage: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var prefix: String? = nil
    
    @State private var isShowingPassword: Bool = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Label
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundColor(.binanceTextSecondary)
                .textCase(.uppercase)
            
            // Input Capsule
            HStack(spacing: 10) {
                // Leading Icon
                Image(systemName: systemImage)
                    .font(.system(size: 15))
                    .foregroundColor(isFocused ? .binanceYellow : .binanceTextSecondary)
                    .frame(width: 20)
                
                // Prefix (e.g., +48)
                if let prefix = prefix {
                    Text(prefix)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.binanceTextPrimary)
                    
                    Rectangle()
                        .fill(Color.binanceBorder)
                        .frame(width: 1, height: 18)
                }
                
                // Text Field / Secure Field
                if isSecure && !isShowingPassword {
                    SecureField(placeholder, text: $text)
                        .font(.system(size: 15))
                        .foregroundColor(.binanceTextPrimary)
                        .focused($isFocused)
                        .tint(.binanceYellow)
                } else {
                    TextField(placeholder, text: $text)
                        .font(.system(size: 15))
                        .foregroundColor(.binanceTextPrimary)
                        .keyboardType(keyboardType)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .focused($isFocused)
                        .tint(.binanceYellow)
                }
                
                // Password Visibility Toggle
                if isSecure {
                    Button(action: {
                        HapticsManager.shared.lightImpact()
                        isShowingPassword.toggle()
                    }) {
                        Image(systemName: isShowingPassword ? "eye.slash.fill" : "eye.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.binanceTextSecondary)
                    }
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 48)
            .background(Color.binanceSurface)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isFocused ? Color.binanceYellow : Color.binanceBorder, lineWidth: isFocused ? 1.5 : 1)
            )
            .animation(.easeInOut(duration: 0.15), value: isFocused)
        }
    }
}
