import SwiftUI

// MARK: - Binance Official Color Palette
extension Color {
    // Backgrounds
    static let binanceBg = Color(hex: "181A20")
    static let binanceCard = Color(hex: "1E2329")
    static let binanceSurface = Color(hex: "2B313A")
    static let binanceSurfaceHover = Color(hex: "333A44")
    static let binanceBorder = Color(hex: "2E333D")
    
    // Binance Yellows
    static let binanceYellow = Color(hex: "F0B90B")
    static let binanceYellowButton = Color(hex: "FCD535")
    static let binanceYellowHover = Color(hex: "FFE251")
    
    // Typography
    static let binanceTextPrimary = Color(hex: "EAECEF")
    static let binanceTextSecondary = Color(hex: "848E9C")
    static let binanceTextMuted = Color(hex: "5E6673")
    static let binanceSubtext = Color(hex: "848E9C")
    static let binanceLine = Color(hex: "2E333D")
    static let binanceGold = Color(hex: "F0B90B")
    
    // Trading Signals
    static let binanceGreen = Color(hex: "0ECB81")
    static let binanceGreenBg = Color(hex: "0ECB81").opacity(0.12)
    static let binanceRed = Color(hex: "F6465D")
    static let binanceRedBg = Color(hex: "F6465D").opacity(0.12)
    
    // Hex Color Initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Binance Custom Button Style with 120 FPS Spring Press Effect
struct BinanceButtonStyle: ButtonStyle {
    var backgroundColor: Color = .binanceYellowButton
    var foregroundColor: Color = .binanceBg
    var isEnabled: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .bold))
            .foregroundColor(isEnabled ? foregroundColor : .binanceTextMuted)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(isEnabled ? (configuration.isPressed ? Color.binanceYellow : backgroundColor) : Color.binanceSurface)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.65), value: configuration.isPressed)
    }
}

// MARK: - Binance Secondary Outline Button Style
struct BinanceOutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.binanceTextPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background(configuration.isPressed ? Color.binanceSurfaceHover : Color.binanceSurface)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.binanceBorder, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.65), value: configuration.isPressed)
    }
}
