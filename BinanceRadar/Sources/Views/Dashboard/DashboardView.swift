import SwiftUI

// MARK: - Binance Pro Mobile Dashboard with 120 FPS Landing Animation
struct DashboardView: View {
    @ObservedObject var viewModel: AuthViewModel
    
    // Animation States for Staggered 120 FPS Landing
    @State private var hasLanded: Bool = false
    @State private var showBalance: Bool = true
    @State private var copiedToken: String? = nil
    @State private var activeBottomTab: Int = 0
    
    // Mock Tickers
    let tickers = [
        ("BTCUSDT", "94,280.50", "+2.84%", true),
        ("ETHUSDT", "3,145.20", "+1.65%", true),
        ("SOLUSDT", "218.40", "-0.92%", false),
        ("BNBUSDT", "642.10", "+1.15%", true),
        ("XAUUSD", "2,684.10", "+0.75%", true)
    ]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background
            Color.binanceBg
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - 1. Top Header Bar (User, VIP, Face ID Badge, Logout)
                HStack(spacing: 12) {
                    // Avatar with Binance Yellow Outline
                    ZStack {
                        Circle()
                            .fill(Color.binanceSurface)
                            .frame(width: 38, height: 38)
                            .overlay(
                                Circle()
                                    .stroke(Color.binanceYellow, lineWidth: 1.5)
                            )
                        
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 34))
                            .foregroundColor(.binanceYellow)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(viewModel.registeredUserPhone.isEmpty ? "Kuba Trader" : viewModel.registeredUserPhone)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.binanceTextPrimary)
                            
                            Text("VIP 1")
                                .font(.system(size: 9, weight: .black, design: .monospaced))
                                .foregroundColor(.binanceYellow)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Color.binanceYellow.opacity(0.15))
                                .cornerRadius(4)
                        }
                        
                        HStack(spacing: 6) {
                            HStack(spacing: 3) {
                                Image(systemName: "faceid")
                                    .font(.system(size: 9))
                                Text("FACE ID")
                                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                            }
                            .foregroundColor(.binanceGreen)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.binanceGreenBg)
                            .cornerRadius(3)
                            
                            Text("UID: 89421098")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.binanceTextMuted)
                        }
                    }
                    
                    Spacer()
                    
                    // Lock / Logout Button (Quick Re-test of Face ID)
                    Button(action: {
                        viewModel.logout()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 11))
                            Text("Zablokuj")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(.binanceRed)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.binanceRedBg)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.binanceRed.opacity(0.25), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 12)
                .background(Color.binanceBg)
                .offset(y: hasLanded ? 0 : -30)
                .opacity(hasLanded ? 1 : 0)
                
                // MARK: - Scrollable Dashboard Content
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        // MARK: - 2. Portfolio Balance Card (Binance Futures Style)
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                HStack(spacing: 6) {
                                    Text("Szacowane Saldo (Wirtualne)")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.binanceTextSecondary)
                                    
                                    Button(action: {
                                        HapticsManager.shared.lightImpact()
                                        showBalance.toggle()
                                    }) {
                                        Image(systemName: showBalance ? "eye.fill" : "eye.slash.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(.binanceTextSecondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Text("Paper Trading 24/7")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(.binanceYellow)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(Color.binanceYellow.opacity(0.12))
                                    .cornerRadius(4)
                            }
                            
                            // Balance Amount
                            HStack(alignment: .firstTextBaseline, spacing: 6) {
                                Text(showBalance ? "14,850.40" : "••••••••")
                                    .font(.system(size: 28, weight: .black, design: .rounded))
                                    .foregroundColor(.binanceTextPrimary)
                                
                                Text("PLN")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.binanceTextSecondary)
                                
                                Spacer()
                                
                                // 24h PnL badge
                                HStack(spacing: 3) {
                                    Image(systemName: "arrow.up.right")
                                        .font(.system(size: 10, weight: .bold))
                                    Text("+1,240.20 PLN (+9.1%)")
                                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                                }
                                .foregroundColor(.binanceGreen)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.binanceGreenBg)
                                .cornerRadius(6)
                            }
                            
                            Divider()
                                .background(Color.binanceBorder)
                            
                            // 3 Mini Stats
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Skuteczność AI")
                                        .font(.system(size: 10))
                                        .foregroundColor(.binanceTextSecondary)
                                    Text("76.4%")
                                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                                        .foregroundColor(.binanceTextPrimary)
                                }
                                Spacer()
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Bilans Zagrań")
                                        .font(.system(size: 10))
                                        .foregroundColor(.binanceTextSecondary)
                                    Text("26 TP / 8 SL")
                                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                                        .foregroundColor(.binanceGreen)
                                }
                                Spacer()
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Kurs USD/PLN")
                                        .font(.system(size: 10))
                                        .foregroundColor(.binanceTextSecondary)
                                    Text("4.08 zł")
                                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                                        .foregroundColor(.binanceYellow)
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.binanceCard)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.binanceBorder, lineWidth: 1)
                        )
                        .scaleEffect(hasLanded ? 1.0 : 0.92)
                        .opacity(hasLanded ? 1 : 0)
                        
                        // MARK: - 3. Quick Action Buttons
                        HStack(spacing: 12) {
                            QuickActionButton(icon: "bolt.fill", title: "Radar AI", color: .binanceYellow)
                            QuickActionButton(icon: "arrow.triangle.2.circlepath", title: "Sygnały", color: .binanceGreen)
                            QuickActionButton(icon: "chart.line.uptrend.xyaxis", title: "PnL Audyt", color: .binanceYellow)
                            QuickActionButton(icon: "shield.lefthalf.filled", title: "Ryzyko", color: .binanceTextPrimary)
                        }
                        .offset(y: hasLanded ? 0 : 20)
                        .opacity(hasLanded ? 1 : 0)
                        
                        // MARK: - 4. Live Tickers Marquee
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("RYNKI NA ŻYWO (RAM 10M)")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(.binanceTextSecondary)
                                Spacer()
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(Color.binanceYellow)
                                        .frame(width: 5, height: 5)
                                    Text("LIVE")
                                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                                        .foregroundColor(.binanceYellow)
                                }
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(tickers, id: \.0) { ticker in
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(ticker.0)
                                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                                .foregroundColor(.binanceTextPrimary)
                                            
                                            Text("$\(ticker.1)")
                                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                                .foregroundColor(.binanceTextPrimary)
                                            
                                            Text(ticker.2)
                                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                                .foregroundColor(ticker.3 ? .binanceGreen : .binanceRed)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(ticker.3 ? Color.binanceGreenBg : Color.binanceRedBg)
                                                .cornerRadius(4)
                                        }
                                        .padding(10)
                                        .frame(width: 118)
                                        .background(Color.binanceCard)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.binanceBorder, lineWidth: 1)
                                        )
                                    }
                                }
                            }
                        }
                        .offset(y: hasLanded ? 0 : 30)
                        .opacity(hasLanded ? 1 : 0)
                        
                        // MARK: - 5. Live Confirmed Signals (Binance Futures Alert Card)
                        VStack(alignment: .leading, spacing: 10) {
                            Text("OSTATNIE SYGNAŁY AI RADARU")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.binanceTextSecondary)
                            
                            SignalCardView(
                                symbol: "BTCUSDT",
                                direction: "LONG / KUPUJ",
                                isLong: true,
                                confidence: "93%",
                                catalyst: "SEC FORM 4 INSIDER",
                                entry: "94,200.00",
                                tp: "97,500.00",
                                sl: "92,800.00",
                                rationale: "MicroStrategy potwierdza zakup 51,780 BTC. Wolumen instytucjonalny przebija opór.",
                                copiedToken: $copiedToken
                            )
                            
                            SignalCardView(
                                symbol: "XAUUSD",
                                direction: "LONG / KUPUJ",
                                isLong: true,
                                confidence: "89%",
                                catalyst: "BLOOMBERG DEPESZA",
                                entry: "2,682.00",
                                tp: "2,710.00",
                                sl: "2,668.00",
                                rationale: "Popyt na bezpieczną przystań po danych o inflacji w USA. Dolar w odwrocie.",
                                copiedToken: $copiedToken
                            )
                        }
                        .offset(y: hasLanded ? 0 : 40)
                        .opacity(hasLanded ? 1 : 0)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    .padding(.bottom, 90) // clearance for bottom navigation
                }
            }
            
            // MARK: - 6. Bottom Navigation Bar (Binance 5-Tab)
            HStack {
                BottomTabItem(icon: "house.fill", title: "Home", isSelected: activeBottomTab == 0) {
                    activeBottomTab = 0
                }
                BottomTabItem(icon: "chart.bar.xaxis", title: "Rynki", isSelected: activeBottomTab == 1) {
                    activeBottomTab = 1
                }
                BottomTabItem(icon: "bolt.horizontal.fill", title: "Radar", isSelected: activeBottomTab == 2) {
                    activeBottomTab = 2
                }
                BottomTabItem(icon: "chart.pie.fill", title: "Futures", isSelected: activeBottomTab == 3) {
                    activeBottomTab = 3
                }
                BottomTabItem(icon: "wallet.pass.fill", title: "Portfel", isSelected: activeBottomTab == 4) {
                    activeBottomTab = 4
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 16)
            .background(Color.binanceCard.ignoresSafeArea(edges: .bottom))
            .overlay(
                Rectangle()
                    .fill(Color.binanceBorder)
                    .frame(height: 1),
                alignment: .top
            )
        }
        .onAppear {
            // Trigger 120 FPS Landing Spring
            withAnimation(.spring(response: 0.55, dampingFraction: 0.72)) {
                hasLanded = true
            }
        }
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        Button(action: {
            HapticsManager.shared.lightImpact()
        }) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.binanceSurface)
                        .frame(height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.binanceTextPrimary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Signal Card View with 1-Tap Copy Buttons
struct SignalCardView: View {
    let symbol: String
    let direction: String
    let isLong: Bool
    let confidence: String
    let catalyst: String
    let entry: String
    let tp: String
    let sl: String
    let rationale: String
    @Binding var copiedToken: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack {
                Text(symbol)
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                    .foregroundColor(.binanceTextPrimary)
                
                Text(catalyst)
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.binanceYellow)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.binanceYellow.opacity(0.12))
                    .cornerRadius(4)
                
                Spacer()
                
                Text(direction)
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundColor(isLong ? .binanceGreen : .binanceRed)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(isLong ? Color.binanceGreenBg : Color.binanceRedBg)
                    .cornerRadius(4)
            }
            
            // Rationale
            Text(rationale)
                .font(.system(size: 12))
                .foregroundColor(.binanceTextSecondary)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.binanceSurface)
                .cornerRadius(8)
            
            // TP / SL 1-Tap Copy Grid
            HStack(spacing: 8) {
                // TP Button
                Button(action: {
                    UIPasteboard.general.string = tp
                    copiedToken = "tp-\(symbol)"
                    HapticsManager.shared.lightImpact()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        if copiedToken == "tp-\(symbol)" { copiedToken = nil }
                    }
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 1) {
                            Text("TAKE PROFIT (TP)")
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .foregroundColor(.binanceGreen)
                            Text("$\(tp)")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.binanceTextPrimary)
                        }
                        Spacer()
                        Image(systemName: copiedToken == "tp-\(symbol)" ? "checkmark" : "doc.on.doc.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.binanceGreen)
                    }
                    .padding(8)
                    .background(Color.binanceSurface)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.binanceGreen.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // SL Button
                Button(action: {
                    UIPasteboard.general.string = sl
                    copiedToken = "sl-\(symbol)"
                    HapticsManager.shared.lightImpact()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        if copiedToken == "sl-\(symbol)" { copiedToken = nil }
                    }
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 1) {
                            Text("STOP LOSS (SL)")
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .foregroundColor(.binanceRed)
                            Text("$\(sl)")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.binanceTextPrimary)
                        }
                        Spacer()
                        Image(systemName: copiedToken == "sl-\(symbol)" ? "checkmark" : "doc.on.doc.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.binanceRed)
                    }
                    .padding(8)
                    .background(Color.binanceSurface)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.binanceRed.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(14)
        .background(Color.binanceCard)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.binanceBorder, lineWidth: 1)
        )
    }
}

// MARK: - Bottom Tab Item
struct BottomTabItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticsManager.shared.lightImpact()
            action()
        }) {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? .binanceYellow : .binanceTextSecondary)
                
                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .binanceYellow : .binanceTextSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
