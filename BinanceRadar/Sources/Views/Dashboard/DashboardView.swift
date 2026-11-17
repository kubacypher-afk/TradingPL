import SwiftUI
import UIKit

// MARK: - Live Desk Timeframe Model
enum LiveDeskTimeframe: String, CaseIterable, Identifiable {
    case live = "• LIVE"
    case oneHour = "1H"
    case fourHours = "4H"
    case oneDay = "1D"
    case oneWeek = "1W"
    case all = "ALL"
    
    var id: String { rawValue }
    
    var earnings: String {
        switch self {
        case .live: return "$10.00"
        case .oneHour: return "$84.50"
        case .fourHours: return "$240.80"
        case .oneDay: return "$680.00"
        case .oneWeek: return "$2,850.00"
        case .all: return "$14,290.00"
        }
    }
    
    var changeText: String {
        switch self {
        case .live: return "+$0.00 (0.00%)"
        case .oneHour: return "+$8.40 (+11.0%)"
        case .fourHours: return "+$32.50 (+15.6%)"
        case .oneDay: return "+$94.20 (+16.1%)"
        case .oneWeek: return "+$410.00 (+16.8%)"
        case .all: return "+$3,420.00 (+31.4%)"
        }
    }
    
    var multiplier: String {
        switch self {
        case .live: return "1.00x"
        case .oneHour: return "1.25x"
        case .fourHours: return "1.50x"
        case .oneDay: return "2.00x"
        case .oneWeek: return "2.50x"
        case .all: return "3.00x"
        }
    }
    
    // Normalized curve points (0.0 bottom, 1.0 top)
    var curvePoints: [CGFloat] {
        switch self {
        case .live:
            return [0.48, 0.49, 0.48, 0.50, 0.49, 0.50, 0.50, 0.51, 0.50, 0.51, 0.50, 0.51]
        case .oneHour:
            return [0.42, 0.45, 0.43, 0.49, 0.47, 0.52, 0.50, 0.56, 0.54, 0.61, 0.63, 0.67]
        case .fourHours:
            return [0.35, 0.38, 0.44, 0.42, 0.50, 0.57, 0.53, 0.60, 0.65, 0.70, 0.68, 0.75]
        case .oneDay:
            return [0.26, 0.31, 0.30, 0.38, 0.46, 0.43, 0.54, 0.62, 0.67, 0.74, 0.78, 0.82]
        case .oneWeek:
            return [0.20, 0.25, 0.33, 0.31, 0.44, 0.52, 0.56, 0.65, 0.73, 0.79, 0.85, 0.91]
        case .all:
            return [0.15, 0.20, 0.27, 0.35, 0.46, 0.55, 0.65, 0.74, 0.83, 0.89, 0.93, 0.97]
        }
    }
}

// MARK: - Bot Trade / Activity Model
struct BotActivityItem: Identifiable {
    let id = UUID()
    let symbol: String
    let pair: String
    let actionType: String
    let triggerReason: String
    let timestamp: String
    let profitAmount: Double
    let profitString: String
    let percentString: String
    let iconName: String
    let badgeColor: Color
}

// MARK: - Found Opportunity Model for Radar
struct FoundTradeOpportunity: Identifiable {
    let id = UUID()
    let ticker: String
    let companyName: String
    let assetType: String // "Akcja US" / "Krypto"
    let signalStrength: String // "Silne Kupno (Strong Buy)"
    let confidenceScore: Double // 98.4%
    let expectedProfit: String // "+$240.00"
    let profitPercent: String // "+24.0%"
    let entryPrice: String // "$142.50"
    let takeProfit: String // "$176.70"
    let stopLoss: String // "$139.65"
    let riskReward: String // "1 : 4.2"
    let catalyst: String // "Wybicie wolumenu +340%, RSI dywergencja"
    let iconName: String
    let brandColor: Color
}

// MARK: - App Navigation Tabs (Now with Radar instead of Markets)
enum AppTab: String, CaseIterable, Identifiable {
    case home = "Home"
    case radar = "Radar"
    case trades = "Trades"
    case wallet = "Wallet"
    case profile = "Profile"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .radar: return "dot.radiowaves.left.and.right"
        case .trades: return "bolt.fill"
        case .wallet: return "wallet.pass.fill"
        case .profile: return "person.crop.circle.fill"
        }
    }
}

// MARK: - Main Dashboard View
struct DashboardView: View {
    @ObservedObject var viewModel: AuthViewModel
    
    @State private var currentTab: AppTab = .home
    @State private var selectedTimeframe: LiveDeskTimeframe = .live
    @State private var livePulse: Bool = false
    @State private var showAllActivities: Bool = false
    @State private var currentPoints: [CGFloat] = LiveDeskTimeframe.live.curvePoints
    
    // MARK: - Radar Tab States
    @State private var isActionRadarActive: Bool = false
    @State private var allocatedCapital: Double = 1000.0
    @State private var maxLossPercent: Double = 3.0 // 3.0% max loss
    @State private var isScanningAnimation: Bool = false
    @State private var radarRotation: Double = 0
    @State private var showFoundNotification: Bool = false
    @State private var selectedOpportunityDetails: FoundTradeOpportunity? = nil
    
    // UI Palette
    private let neonGreen = Color(hex: "#00FFA3")
    private let darkBg = Color(hex: "#05070A")
    private let cardBg = Color(hex: "#0E1217")
    private let pillBg = Color(hex: "#13171F")
    private let borderDark = Color(hex: "#1B222C")
    
    // Opportunity detected by bot algorithm
    private let activeOpportunity = FoundTradeOpportunity(
        ticker: "NVDA",
        companyName: "NVIDIA Corporation",
        assetType: "Akcja NASDAQ",
        signalStrength: "SILNE KUPNO (STRONG BUY)",
        confidenceScore: 98.4,
        expectedProfit: "+$240.00",
        profitPercent: "+24.0%",
        entryPrice: "$142.50",
        takeProfit: "$176.70",
        stopLoss: "$138.20",
        riskReward: "1 : 4.2",
        catalyst: "Instytucjonalny skok wolumenu +340%, wybicie z flagi byka, rekomendacje analityków",
        iconName: "cpu.fill",
        brandColor: Color(hex: "#76B900")
    )
    
    // Activity data (Recent bot trades and earnings)
    private let recentActivities: [BotActivityItem] = [
        BotActivityItem(
            symbol: "SOL",
            pair: "SOL / USDT",
            actionType: "Long Scalp",
            triggerReason: "Take Profit 100%",
            timestamp: "2m ago",
            profitAmount: 42.80,
            profitString: "+$42.80",
            percentString: "+14.2%",
            iconName: "s.circle.fill",
            badgeColor: Color(hex: "#9945FF")
        ),
        BotActivityItem(
            symbol: "BTC",
            pair: "BTC / USDT",
            actionType: "Breakout",
            triggerReason: "Auto Compound Exit",
            timestamp: "18m ago",
            profitAmount: 118.50,
            profitString: "+$118.50",
            percentString: "+8.9%",
            iconName: "bitcoinsign.circle.fill",
            badgeColor: Color(hex: "#F7931A")
        ),
        BotActivityItem(
            symbol: "ETH",
            pair: "ETH / USDT",
            actionType: "Momentum",
            triggerReason: "Trailing Stop Hit",
            timestamp: "45m ago",
            profitAmount: 27.40,
            profitString: "+$27.40",
            percentString: "+6.4%",
            iconName: "diamond.fill",
            badgeColor: Color(hex: "#627EEA")
        ),
        BotActivityItem(
            symbol: "PEPE",
            pair: "PEPE / USDT",
            actionType: "Volatility Grid",
            triggerReason: "Grid Cycle Closed",
            timestamp: "2h ago",
            profitAmount: 64.10,
            profitString: "+$64.10",
            percentString: "+24.8%",
            iconName: "flame.fill",
            badgeColor: Color(hex: "#00E676")
        ),
        BotActivityItem(
            symbol: "SUI",
            pair: "SUI / USDT",
            actionType: "Trend Ride",
            triggerReason: "Target 2 Reached",
            timestamp: "4h ago",
            profitAmount: 19.90,
            profitString: "+$19.90",
            percentString: "+11.5%",
            iconName: "water.waves",
            badgeColor: Color(hex: "#2A82E4")
        )
    ]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Dark Background
            darkBg
                .ignoresSafeArea()
            
            // Tab Content
            Group {
                switch currentTab {
                case .home:
                    homeDeskContent
                case .radar:
                    radarDeskContent
                case .trades:
                    tradesPlaceholderView
                case .wallet:
                    walletPlaceholderView
                case .profile:
                    profilePlaceholderView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Top Live In-App Notification (When Radar finds an action)
            if showFoundNotification {
                liveOpportunityBanner
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(100)
            }
            
            // Docked Bottom Tab Navigation Bar
            bottomTabBar
                .zIndex(50)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                livePulse = true
            }
        }
        .sheet(item: $selectedOpportunityDetails) { opportunity in
            opportunityDetailSheet(opportunity)
        }
    }
    
    // MARK: - ================= HOME TAB =================
    // Ultra-clean: Clutter purged (No < Trading Desk, Share, lock, Grok Bot, or fomo subtitle)
    private var homeDeskContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Clean Top Spacing (replaces old cluttered header)
                HStack {
                    // Small discreet live pulse dot
                    HStack(spacing: 6) {
                        Circle()
                            .fill(neonGreen)
                            .frame(width: 7, height: 7)
                            .shadow(color: neonGreen.opacity(0.8), radius: livePulse ? 5 : 2)
                        
                        Text("LIVE DESK")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(neonGreen.opacity(0.9))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(hex: "#0A1F18"))
                    .clipShape(Capsule())
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 54)
                
                // Big Balance and PnL Multiplier
                balanceSection
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                
                // Glowing Neon Green Curve Chart
                chartSection
                    .frame(height: 135)
                    .padding(.top, 12)
                    .padding(.bottom, 20)
                
                // Timeframe Selector with unwrapped clean pills
                timeframeSelector
                    .padding(.horizontal, 18)
                    .padding(.bottom, 26)
                
                // Activity Section (Recent Bot Trades & Earnings)
                activitySection
                    .padding(.horizontal, 20)
                    .padding(.bottom, 125) // Prevent overlap with bottom dock
            }
        }
    }
    
    // MARK: - Clean Balance Section
    private var balanceSection: some View {
        HStack(alignment: .center, spacing: 10) {
            // Large Bold Earnings Display
            Text(selectedTimeframe.earnings)
                .font(.system(size: 44, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .tracking(0.5)
            
            // Green PnL Pill (▲ +$0.00 (0.00%))
            HStack(spacing: 4) {
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 11, weight: .bold))
                Text(selectedTimeframe.changeText)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
            }
            .foregroundColor(neonGreen)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(hex: "#0C1F19"))
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(neonGreen.opacity(0.25), lineWidth: 1)
            )
            
            // Multiplier Pill (1.00x)
            Text(selectedTimeframe.multiplier)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(Color(hex: "#848E9C"))
                .padding(.horizontal, 9)
                .padding(.vertical, 6)
                .background(pillBg)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(borderDark, lineWidth: 1)
                )
            
            Spacer()
        }
    }
    
    // MARK: - Chart Section
    private var chartSection: some View {
        GeometryReader { chartProxy in
            let w = chartProxy.size.width
            let h = chartProxy.size.height
            let points = currentPoints
            let lastY = h * (1.0 - (points.last ?? 0.5))
            let lastX = w
            
            ZStack {
                // Radiant Gradient Fill Underneath
                LiveDeskChartFill(points: points)
                    .fill(
                        LinearGradient(
                            colors: [
                                neonGreen.opacity(0.22),
                                neonGreen.opacity(0.06),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                // Neon Stroke Line
                LiveDeskChartPath(points: points)
                    .stroke(
                        neonGreen,
                        style: StrokeStyle(lineWidth: 2.6, lineCap: .round, lineJoin: .round)
                    )
                    .shadow(color: neonGreen.opacity(0.75), radius: 6, x: 0, y: 0)
                
                // Glowing Pulse Dot on Tip
                ZStack {
                    Circle()
                        .fill(neonGreen.opacity(0.35))
                        .frame(width: 14, height: 14)
                        .scaleEffect(livePulse ? 1.4 : 1.0)
                    
                    Circle()
                        .fill(neonGreen)
                        .frame(width: 7, height: 7)
                }
                .position(x: lastX, y: lastY)
                .shadow(color: neonGreen, radius: 8)
            }
        }
    }
    
    // MARK: - Timeframe Selector (Guaranteed No Text Wrapping)
    private var timeframeSelector: some View {
        HStack(spacing: 6) {
            ForEach(LiveDeskTimeframe.allCases) { tf in
                Button(action: {
                    HapticsManager.shared.lightImpact()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selectedTimeframe = tf
                        currentPoints = tf.curvePoints
                    }
                }) {
                    Text(tf.rawValue)
                        .font(.system(size: 13, weight: selectedTimeframe == tf ? .heavy : .semibold))
                        .foregroundColor(selectedTimeframe == tf ? Color.black : Color(hex: "#7D8693"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                        .frame(maxWidth: .infinity)
                        .frame(height: 34)
                        .background(
                            ZStack {
                                if selectedTimeframe == tf {
                                    Capsule()
                                        .fill(neonGreen)
                                        .shadow(color: neonGreen.opacity(0.6), radius: 8, x: 0, y: 2)
                                } else {
                                    Capsule()
                                        .fill(pillBg.opacity(0.6))
                                }
                            }
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // MARK: - Activity Section
    private var activitySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header Row: "Activity" and "See all"
            HStack {
                Text("Activity")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    HapticsManager.shared.lightImpact()
                    showAllActivities.toggle()
                }) {
                    Text(showAllActivities ? "Show less" : "See all")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(neonGreen)
                }
            }
            
            // List of Recent Bot Actions with Earnings
            VStack(spacing: 10) {
                ForEach(showAllActivities ? recentActivities : Array(recentActivities.prefix(4))) { item in
                    activityRow(item)
                }
            }
        }
    }
    
    private func activityRow(_ item: BotActivityItem) -> some View {
        HStack(spacing: 12) {
            // Token Icon Badge
            ZStack {
                Circle()
                    .fill(item.badgeColor.opacity(0.18))
                    .frame(width: 42, height: 42)
                
                Image(systemName: item.iconName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(item.badgeColor)
            }
            
            // Trade Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(item.pair)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("·")
                        .foregroundColor(Color(hex: "#5E6673"))
                    
                    Text(item.actionType)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "#848E9C"))
                }
                
                HStack(spacing: 6) {
                    Text(item.timestamp)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color(hex: "#5E6673"))
                    
                    Text("·")
                        .foregroundColor(Color(hex: "#5E6673"))
                    
                    Text(item.triggerReason)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(neonGreen.opacity(0.85))
                }
            }
            
            Spacer()
            
            // Profit Earned Badge
            VStack(alignment: .trailing, spacing: 4) {
                Text(item.profitString)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(neonGreen)
                
                Text(item.percentString)
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(neonGreen.opacity(0.8))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(hex: "#0A1F18"))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(neonGreen.opacity(0.2), lineWidth: 1)
            )
        }
        .padding(14)
        .background(cardBg)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(borderDark, lineWidth: 1)
        )
    }
    
    // MARK: - ================= RADAR TAB =================
    // Action Mode, Capital Setup, Max Loss, Live Scanning, Push Notifications & Trade Details
    private var radarDeskContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // 1. Radar Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("RADAR BOT")
                            .font(.system(size: 12, weight: .black, design: .monospaced))
                            .foregroundColor(neonGreen)
                        
                        Text("Skaner Rynku & Akcji")
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Radar Status Badge
                    HStack(spacing: 6) {
                        Circle()
                            .fill(isActionRadarActive ? neonGreen : Color.gray)
                            .frame(width: 8, height: 8)
                            .shadow(color: isActionRadarActive ? neonGreen.opacity(0.9) : Color.clear, radius: 5)
                        
                        Text(isActionRadarActive ? "AKTYWNY" : "STANDBY")
                            .font(.system(size: 11, weight: .heavy, design: .monospaced))
                            .foregroundColor(isActionRadarActive ? neonGreen : Color.gray)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(isActionRadarActive ? Color(hex: "#0A1F18") : pillBg)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(isActionRadarActive ? neonGreen.opacity(0.4) : borderDark, lineWidth: 1)
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 54)
                
                // 2. Big Action Mode Toggle Button ("Tryb Akcji")
                Button(action: {
                    toggleActionMode()
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: isActionRadarActive ? [Color(hex: "#0E281F"), Color(hex: "#0A1B15")] : [Color(hex: "#141922"), Color(hex: "#0E131A")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(isActionRadarActive ? neonGreen : borderDark, lineWidth: isActionRadarActive ? 2 : 1)
                            )
                            .shadow(color: isActionRadarActive ? neonGreen.opacity(0.3) : Color.clear, radius: 15)
                        
                        HStack(spacing: 16) {
                            // Animated Radar Sweep Dish Icon
                            ZStack {
                                Circle()
                                    .fill(isActionRadarActive ? neonGreen.opacity(0.18) : Color.white.opacity(0.06))
                                    .frame(width: 56, height: 56)
                                
                                if isActionRadarActive {
                                    Circle()
                                        .stroke(neonGreen.opacity(0.4), lineWidth: 1)
                                        .frame(width: 44, height: 44)
                                    
                                    // Rotating sweep line
                                    Rectangle()
                                        .fill(
                                            LinearGradient(colors: [neonGreen, Color.clear], startPoint: .top, endPoint: .bottom)
                                        )
                                        .frame(width: 2, height: 22)
                                        .offset(y: -11)
                                        .rotationEffect(.degrees(radarRotation))
                                }
                                
                                Image(systemName: "dot.radiowaves.left.and.right")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(isActionRadarActive ? neonGreen : Color(hex: "#848E9C"))
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("TRYB AKCJI")
                                    .font(.system(size: 18, weight: .black))
                                    .foregroundColor(.white)
                                
                                Text(isActionRadarActive ? "Algorytm szuka okazji z bota w czasie rzeczywistym..." : "Dotknij, aby uruchomić automatyczne skanowanie")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(isActionRadarActive ? neonGreen.opacity(0.9) : Color(hex: "#848E9C"))
                                    .lineLimit(2)
                            }
                            
                            Spacer()
                            
                            // Visual Switch Pill
                            ZStack(alignment: isActionRadarActive ? .trailing : .leading) {
                                Capsule()
                                    .fill(isActionRadarActive ? neonGreen : Color(hex: "#262D38"))
                                    .frame(width: 52, height: 30)
                                
                                Circle()
                                    .fill(isActionRadarActive ? Color.black : Color.white)
                                    .frame(width: 24, height: 24)
                                    .padding(.horizontal, 3)
                            }
                        }
                        .padding(18)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 20)
                
                // 3. Configuration Parameters: Capital & Max Loss ("pod spodem ustawiamy kapitał i maksymalna strata")
                VStack(spacing: 16) {
                    // Header of Config Card
                    HStack {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(neonGreen)
                        Text("Zarządzanie Kapitałem i Ryzykiem")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    
                    // Parameter A: Kapitał
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Twój Kapitał na Akcję:")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(hex: "#848E9C"))
                            Spacer()
                            Text("$\(Int(allocatedCapital)) USD")
                                .font(.system(size: 17, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                        }
                        
                        Slider(value: $allocatedCapital, in: 100...10000, step: 50)
                            .accentColor(neonGreen)
                        
                        // Quick Capital Chips
                        HStack(spacing: 8) {
                            ForEach([250.0, 500.0, 1000.0, 2500.0, 5000.0], id: \.self) { cap in
                                Button(action: {
                                    HapticsManager.shared.lightImpact()
                                    withAnimation { allocatedCapital = cap }
                                }) {
                                    Text("$\(Int(cap))")
                                        .font(.system(size: 11, weight: allocatedCapital == cap ? .bold : .medium))
                                        .foregroundColor(allocatedCapital == cap ? Color.black : Color(hex: "#848E9C"))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(allocatedCapital == cap ? neonGreen : pillBg)
                                        .clipShape(Capsule())
                                        .overlay(Capsule().stroke(borderDark, lineWidth: 1))
                                }
                            }
                        }
                    }
                    .padding(14)
                    .background(pillBg.opacity(0.8))
                    .cornerRadius(12)
                    
                    // Parameter B: Maksymalna Strata (Max Loss / Stop Loss)
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Maksymalna Dopuszczalna Strata:")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(hex: "#848E9C"))
                            Spacer()
                            let lossDollar = allocatedCapital * (maxLossPercent / 100.0)
                            Text("-\(String(format: "%.1f", maxLossPercent))% (-$\(Int(lossDollar)))")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(hex: "#F6465D"))
                        }
                        
                        Slider(value: $maxLossPercent, in: 1.0...10.0, step: 0.5)
                            .accentColor(Color(hex: "#F6465D"))
                        
                        // Safety Explanation
                        HStack(spacing: 6) {
                            Image(systemName: "shield.checkmark.fill")
                                .font(.system(size: 12))
                                .foregroundColor(neonGreen)
                            Text("Automatyczny Stop Loss natychmiast zabezpieczy kapitał")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(Color(hex: "#848E9C"))
                        }
                    }
                    .padding(14)
                    .background(pillBg.opacity(0.8))
                    .cornerRadius(12)
                }
                .padding(18)
                .background(cardBg)
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(borderDark, lineWidth: 1)
                )
                .padding(.horizontal, 20)
                
                // 4. Znaleziona Akcja (Szczegóły akcji: co to, ile zarobek, wszystkie szczegóły)
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Image(systemName: "target")
                            .foregroundColor(neonGreen)
                        Text("Ostatnio Wykryta Okazja z Bota")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        
                        Text("LIVE SYGNAŁ")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundColor(neonGreen)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(hex: "#0A1F18"))
                            .clipShape(Capsule())
                    }
                    
                    // Main Opportunity Card
                    opportunityCard(activeOpportunity)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 125)
            }
        }
    }
    
    // MARK: - Opportunity Card (Szczegóły znalezionej akcji)
    private func opportunityCard(_ item: FoundTradeOpportunity) -> some View {
        VStack(spacing: 16) {
            // Header Row: Ticker, Type, Signal
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(item.brandColor.opacity(0.18))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: item.iconName)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(item.brandColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(item.ticker)
                            .font(.system(size: 20, weight: .black))
                            .foregroundColor(.white)
                        
                        Text(item.assetType)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(hex: "#848E9C"))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(pillBg)
                            .clipShape(Capsule())
                    }
                    
                    Text(item.companyName)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "#848E9C"))
                }
                
                Spacer()
                
                // Expected Profit Display
                VStack(alignment: .trailing, spacing: 3) {
                    Text(item.expectedProfit)
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(neonGreen)
                    
                    Text(item.profitPercent)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(neonGreen.opacity(0.85))
                }
            }
            
            Divider()
                .background(borderDark)
            
            // Key Trade Metrics: Entry, Take Profit, Stop Loss, Risk/Reward
            HStack(spacing: 0) {
                tradeMetricCol(title: "WEJŚCIE", value: item.entryPrice, color: .white)
                Spacer()
                tradeMetricCol(title: "TAKE PROFIT", value: item.takeProfit, color: neonGreen)
                Spacer()
                tradeMetricCol(title: "STOP LOSS", value: item.stopLoss, color: Color(hex: "#F6465D"))
                Spacer()
                tradeMetricCol(title: "R : R", value: item.riskReward, color: Color(hex: "#FCD535"))
            }
            .padding(.horizontal, 4)
            
            // AI Bot Reasoning Catalyst
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 12))
                    .foregroundColor(neonGreen)
                
                Text(item.catalyst)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "#B7BDC6"))
                    .lineLimit(2)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: "#081510"))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(neonGreen.opacity(0.18), lineWidth: 1)
            )
            
            // Action Buttons: "Szczegóły Akcji" & "Wykonaj Transakcję"
            HStack(spacing: 12) {
                Button(action: {
                    HapticsManager.shared.lightImpact()
                    selectedOpportunityDetails = item
                }) {
                    Text("Szczegóły Akcji")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(pillBg)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(borderDark, lineWidth: 1)
                        )
                }
                
                Button(action: {
                    HapticsManager.shared.notifySuccess()
                    // Auto-execute trade simulation
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill")
                        Text("Auto-Trade")
                    }
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(neonGreen)
                    .cornerRadius(12)
                    .shadow(color: neonGreen.opacity(0.4), radius: 8, x: 0, y: 3)
                }
            }
        }
        .padding(18)
        .background(cardBg)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(neonGreen.opacity(0.3), lineWidth: 1)
        )
    }
    
    private func tradeMetricCol(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(Color(hex: "#848E9C"))
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
    }
    
    // MARK: - Live In-App Push Notification Banner
    private var liveOpportunityBanner: some View {
        VStack {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(neonGreen.opacity(0.2))
                        .frame(width: 38, height: 38)
                    Image(systemName: "bell.badge.fill")
                        .foregroundColor(neonGreen)
                        .font(.system(size: 16))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Radar Bota: Nowa Okazja!")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Text("NVDA: Oczekiwany zysk +$240.00 (+24%)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(neonGreen)
                }
                
                Spacer()
                
                Button(action: {
                    HapticsManager.shared.lightImpact()
                    withAnimation { showFoundNotification = false }
                    selectedOpportunityDetails = activeOpportunity
                }) {
                    Text("Sprawdź")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundColor(.black)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(neonGreen)
                        .clipShape(Capsule())
                }
            }
            .padding(14)
            .background(Color(hex: "#0E1C15"))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(neonGreen.opacity(0.6), lineWidth: 1)
            )
            .shadow(color: neonGreen.opacity(0.3), radius: 14, x: 0, y: 4)
            .padding(.horizontal, 16)
            .padding(.top, 50)
            
            Spacer()
        }
    }
    
    // MARK: - Action Mode Toggle Logic
    private func toggleActionMode() {
        HapticsManager.shared.mediumImpact()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            isActionRadarActive.toggle()
        }
        
        if isActionRadarActive {
            // Start radar sweep rotation
            withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                radarRotation = 360
            }
            
            // Trigger in-app live notification after 1.8 seconds simulating bot detection
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                HapticsManager.shared.notifySuccess()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    showFoundNotification = true
                }
                
                // Auto hide banner after 6 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                    withAnimation {
                        showFoundNotification = false
                    }
                }
            }
        } else {
            radarRotation = 0
            showFoundNotification = false
        }
    }
    
    // MARK: - Opportunity Detail Sheet (Wszystkie szczegóły akcji)
    private func opportunityDetailSheet(_ item: FoundTradeOpportunity) -> some View {
        ZStack {
            darkBg.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("SZCZEGÓŁY AKCJI")
                            .font(.system(size: 11, weight: .black, design: .monospaced))
                            .foregroundColor(neonGreen)
                        Text(item.companyName)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Button("Zamknij") {
                        selectedOpportunityDetails = nil
                    }
                    .foregroundColor(Color(hex: "#848E9C"))
                }
                .padding(.top, 24)
                
                // Profit Hero Box
                VStack(spacing: 6) {
                    Text("Prognozowany Zysk:")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "#848E9C"))
                    Text(item.expectedProfit)
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundColor(neonGreen)
                    Text("Zwrot z kapitału: \(item.profitPercent)")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(neonGreen.opacity(0.85))
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(cardBg)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(borderDark, lineWidth: 1))
                
                // Full Spec List
                VStack(spacing: 12) {
                    specRow(label: "Ticker & Giełda", val: "\(item.ticker) (NASDAQ)")
                    specRow(label: "Rekomendacja Bota", val: item.signalStrength)
                    specRow(label: "AI Confidence", val: "\(String(format: "%.1f", item.confidenceScore))%")
                    specRow(label: "Cena Wejścia", val: item.entryPrice)
                    specRow(label: "Take Profit Target", val: item.takeProfit)
                    specRow(label: "Stop Loss Ochronny", val: item.stopLoss)
                    specRow(label: "Stosunek Zysku do Ryzyka", val: item.riskReward)
                    specRow(label: "Kapitał Operacyjny", val: "$\(Int(allocatedCapital)) USD")
                    specRow(label: "Zabezpieczona Strata", val: "Max $\(Int(allocatedCapital * (maxLossPercent / 100.0))) USD")
                }
                .padding(16)
                .background(cardBg)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(borderDark, lineWidth: 1))
                
                Spacer()
                
                // Big Confirm Button
                Button(action: {
                    HapticsManager.shared.notifySuccess()
                    selectedOpportunityDetails = nil
                }) {
                    Text("Otwórz Pozycję Zgodnie ze Strategią")
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(neonGreen)
                        .cornerRadius(14)
                        .shadow(color: neonGreen.opacity(0.4), radius: 10, x: 0, y: 3)
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func specRow(label: String, val: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color(hex: "#848E9C"))
            Spacer()
            Text(val)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Bottom Navigation Tab Bar (Home, Radar, Trades, Wallet, Profile)
    private var bottomTabBar: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                Button(action: {
                    HapticsManager.shared.lightImpact()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        currentTab = tab
                    }
                }) {
                    VStack(spacing: 5) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 19, weight: currentTab == tab ? .bold : .regular))
                            .foregroundColor(currentTab == tab ? neonGreen : Color(hex: "#6C7584"))
                            .scaleEffect(currentTab == tab ? 1.08 : 1.0)
                        
                        Text(tab.rawValue)
                            .font(.system(size: 10, weight: currentTab == tab ? .bold : .medium))
                            .foregroundColor(currentTab == tab ? neonGreen : Color(hex: "#6C7584"))
                        
                        // Active Indicator Dot
                        Circle()
                            .fill(currentTab == tab ? neonGreen : Color.clear)
                            .frame(width: 4, height: 4)
                            .shadow(color: neonGreen.opacity(0.8), radius: 3)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 10)
        .padding(.bottom, 22)
        .background(
            ZStack {
                Color(hex: "#0B0E13").opacity(0.96)
                
                VStack {
                    Rectangle()
                        .fill(borderDark)
                        .frame(height: 1)
                    Spacer()
                }
            }
            .ignoresSafeArea(edges: .bottom)
        )
    }
    
    // MARK: - Placeholders for other tabs
    private var tradesPlaceholderView: some View {
        VStack(spacing: 20) {
            Text("Bot Execution Terminal")
                .font(.title2.bold())
                .foregroundColor(.white)
            Text("Autonomous DCA & Grid execution active")
                .foregroundColor(neonGreen)
        }
        .padding(.bottom, 80)
    }
    
    private var walletPlaceholderView: some View {
        VStack(spacing: 20) {
            Text("Trading Wallet")
                .font(.title2.bold())
                .foregroundColor(.white)
            Text("Portfolio balance & hot storage")
                .foregroundColor(Color.binanceTextSecondary)
        }
        .padding(.bottom, 80)
    }
    
    private var profilePlaceholderView: some View {
        VStack(spacing: 20) {
            Text("Security & Settings")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            Button("Log Out") {
                viewModel.logout()
            }
            .foregroundColor(.red)
            .padding(.top, 10)
        }
        .padding(.bottom, 80)
    }
}

// MARK: - Bezier Curved Chart Line Shape
struct LiveDeskChartPath: Shape {
    var points: [CGFloat]
    
    var animatableData: [CGFloat] {
        get { points }
        set { points = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard points.count > 1 else { return path }
        
        let stepX = rect.width / CGFloat(points.count - 1)
        let firstY = rect.height * (1.0 - points[0])
        path.move(to: CGPoint(x: 0, y: firstY))
        
        for i in 1..<points.count {
            let p0 = CGPoint(x: CGFloat(i - 1) * stepX, y: rect.height * (1.0 - points[i - 1]))
            let p1 = CGPoint(x: CGFloat(i) * stepX, y: rect.height * (1.0 - points[i]))
            let midX = (p0.x + p1.x) / 2
            
            path.addCurve(
                to: p1,
                control1: CGPoint(x: midX, y: p0.y),
                control2: CGPoint(x: midX, y: p1.y)
            )
        }
        return path
    }
}

// MARK: - Chart Radiant Gradient Fill
struct LiveDeskChartFill: Shape {
    var points: [CGFloat]
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard points.count > 1 else { return path }
        
        let stepX = rect.width / CGFloat(points.count - 1)
        let firstY = rect.height * (1.0 - points[0])
        
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: firstY))
        
        for i in 1..<points.count {
            let p0 = CGPoint(x: CGFloat(i - 1) * stepX, y: rect.height * (1.0 - points[i - 1]))
            let p1 = CGPoint(x: CGFloat(i) * stepX, y: rect.height * (1.0 - points[i]))
            let midX = (p0.x + p1.x) / 2
            
            path.addCurve(
                to: p1,
                control1: CGPoint(x: midX, y: p0.y),
                control2: CGPoint(x: midX, y: p1.y)
            )
        }
        
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()
        return path
    }
}