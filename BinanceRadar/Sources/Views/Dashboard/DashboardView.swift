import SwiftUI
import UIKit

// MARK: - Live Desk Timeframe Model
enum LiveDeskTimeframe: String, CaseIterable, Identifiable {
    case live = "LIVE"
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

// MARK: - App Navigation Tabs
enum AppTab: String, CaseIterable, Identifiable {
    case home = "Home"
    case markets = "Markets"
    case trades = "Trades"
    case wallet = "Wallet"
    case profile = "Profile"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .markets: return "chart.xyaxis.line"
        case .trades: return "bolt.fill"
        case .wallet: return "wallet.pass.fill"
        case .profile: return "person.crop.circle.fill"
        }
    }
}

// MARK: - Main Dashboard View with Bottom Tab Bar
struct DashboardView: View {
    @ObservedObject var viewModel: AuthViewModel
    
    @State private var currentTab: AppTab = .home
    @State private var selectedTimeframe: LiveDeskTimeframe = .live
    @State private var livePulse: Bool = false
    @State private var isSharing: Bool = false
    @State private var showAllActivities: Bool = false
    @State private var currentPoints: [CGFloat] = LiveDeskTimeframe.live.curvePoints
    
    // UI Palette matching user reference
    private let neonGreen = Color(hex: "#00FFA3")
    private let darkBg = Color(hex: "#05070A")
    private let cardBg = Color(hex: "#0F1318")
    private let pillBg = Color(hex: "#12171E")
    private let borderDark = Color(hex: "#1A222C")
    
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
                case .markets:
                    marketsPlaceholderView
                case .trades:
                    tradesPlaceholderView
                case .wallet:
                    walletPlaceholderView
                case .profile:
                    profilePlaceholderView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Bottom Tab Navigation Bar
            bottomTabBar
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                livePulse = true
            }
        }
        .sheet(isPresented: $isSharing) {
            ShareSheet(activityItems: ["TradingPL Desk: \(selectedTimeframe.earnings) \(selectedTimeframe.changeText)"])
        }
    }
    
    // MARK: - Home Tab Content (1:1 with Screenshot, No Agents, With Activity)
    private var homeDeskContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // 1. Top Navigation & Status Bar (Matching Screenshot)
                topHeaderBar
                    .padding(.horizontal, 20)
                    .padding(.top, 52)
                
                // 2. Earnings and Multiplier Row
                balanceSection
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                
                // 3. Glowing Neon Green Curve Chart
                chartSection
                    .frame(height: 140)
                    .padding(.top, 16)
                    .padding(.bottom, 20)
                
                // 4. Timeframe Selector (LIVE, 1H, 4H, 1D, 1W, ALL)
                timeframeSelector
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
                
                // 5. Activity Section (Recent Actions & Earnings Per Action)
                activitySection
                    .padding(.horizontal, 20)
                    .padding(.bottom, 110) // Space for bottom tab bar
            }
        }
    }
    
    // MARK: - 1. Top Header Bar
    private var topHeaderBar: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                // Back Chevron and "Trading Desk"
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Trading Desk")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Share Capsule Button
                Button(action: {
                    HapticsManager.shared.lightImpact()
                    isSharing = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 13, weight: .semibold))
                        Text("Share")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 7)
                    .background(pillBg)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(borderDark, lineWidth: 1)
                    )
                }
                
                // Discreet lock / sign out
                Button(action: {
                    HapticsManager.shared.lightImpact()
                    viewModel.logout()
                }) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 11))
                        .foregroundColor(Color.binanceTextSecondary)
                        .padding(8)
                        .background(pillBg)
                        .clipShape(Circle())
                }
                .padding(.leading, 4)
            }
            
            // Subtitle Row: Bot Avatar, "Grok Bot >", "• Live", and Details
            HStack(spacing: 8) {
                // Bot Icon Circle
                ZStack {
                    Circle()
                        .fill(Color(hex: "#EAECEF"))
                        .frame(width: 22, height: 22)
                    
                    Image(systemName: "quote.opening")
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(.black)
                }
                
                // Bot Title
                HStack(spacing: 4) {
                    Text("Grok Bot")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(hex: "#848E9C"))
                }
                
                // "• Live" Pill
                HStack(spacing: 5) {
                    Circle()
                        .fill(neonGreen)
                        .frame(width: 6, height: 6)
                        .shadow(color: neonGreen.opacity(0.8), radius: livePulse ? 4 : 2)
                    
                    Text("Live")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(neonGreen)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color(hex: "#0A1F18"))
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(neonGreen.opacity(0.3), lineWidth: 1)
                )
                
                Spacer()
            }
            
            // Bot Telemetry Tagline
            Text("fomo via pilot.py · Compounder 60% · 0 open")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(Color(hex: "#848E9C"))
        }
    }
    
    // MARK: - 2. Balance & Multiplier Section
    private var balanceSection: some View {
        HStack(alignment: .center, spacing: 12) {
            // Large Bold Earnings Display
            Text(selectedTimeframe.earnings)
                .font(.system(size: 44, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .tracking(0.5)
            
            // Green PnL Pill (e.g. ▲ +$0.00 (0.00%))
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
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(pillBg)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(borderDark, lineWidth: 1)
                )
            
            Spacer()
        }
    }
    
    // MARK: - 3. Chart Section with Radiant Glow
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
    
    // MARK: - 4. Timeframe Selector Pills
    private var timeframeSelector: some View {
        HStack(spacing: 8) {
            ForEach(LiveDeskTimeframe.allCases) { tf in
                Button(action: {
                    HapticsManager.shared.lightImpact()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selectedTimeframe = tf
                        currentPoints = tf.curvePoints
                    }
                }) {
                    HStack(spacing: 5) {
                        if tf == .live {
                            Circle()
                                .fill(selectedTimeframe == tf ? Color.black : neonGreen)
                                .frame(width: 5, height: 5)
                        }
                        
                        Text(tf.rawValue)
                            .font(.system(size: 13, weight: selectedTimeframe == tf ? .heavy : .semibold))
                    }
                    .foregroundColor(selectedTimeframe == tf ? Color.black : Color(hex: "#7D8693"))
                    .padding(.horizontal, tf == .live ? 16 : 12)
                    .frame(height: 34)
                    .background(
                        ZStack {
                            if selectedTimeframe == tf {
                                Capsule()
                                    .fill(neonGreen)
                                    .shadow(color: neonGreen.opacity(0.6), radius: 8, x: 0, y: 2)
                            }
                        }
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                if tf != LiveDeskTimeframe.allCases.last {
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - 5. Activity Section (Bot Actions & Profit Per Action)
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
    
    // MARK: - Activity Row Card
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
    
    // MARK: - Bottom Navigation Tab Bar ("Pasek z zakładkami na dole")
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
    
    // MARK: - Placeholder Tabs
    private var marketsPlaceholderView: some View {
        VStack(spacing: 20) {
            Text("Live Markets Watchlist")
                .font(.title2.bold())
                .foregroundColor(.white)
            Text("Real-time order books & radar scanners")
                .foregroundColor(Color.binanceTextSecondary)
        }
        .padding(.bottom, 80)
    }
    
    private var tradesPlaceholderView: some View {
        VStack(spacing: 20) {
            Text("Bot Engine Terminal")
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

// MARK: - Native iOS Share Sheet Wrapper
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}