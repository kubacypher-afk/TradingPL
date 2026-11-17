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
        case .live: return "$14,820.50"
        case .oneHour: return "$842.10"
        case .fourHours: return "$2,480.30"
        case .oneDay: return "$6,920.80"
        case .oneWeek: return "$28,450.00"
        case .all: return "$142,890.00"
        }
    }
    
    var changeText: String {
        switch self {
        case .live: return "+$1,420.50 (10.6%)"
        case .oneHour: return "+$84.20 (1.20%)"
        case .fourHours: return "+$312.40 (4.80%)"
        case .oneDay: return "+$890.50 (8.20%)"
        case .oneWeek: return "+$4,120.00 (18.4%)"
        case .all: return "+$34,200.00 (42.5%)"
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
            return [0.50, 0.50, 0.50, 0.51, 0.50, 0.52, 0.51, 0.53, 0.52, 0.54, 0.53, 0.55]
        case .oneHour:
            return [0.42, 0.44, 0.40, 0.47, 0.49, 0.46, 0.52, 0.54, 0.58, 0.60, 0.63, 0.66]
        case .fourHours:
            return [0.36, 0.39, 0.43, 0.41, 0.49, 0.56, 0.53, 0.59, 0.63, 0.69, 0.67, 0.73]
        case .oneDay:
            return [0.28, 0.32, 0.30, 0.37, 0.44, 0.42, 0.52, 0.60, 0.64, 0.72, 0.76, 0.80]
        case .oneWeek:
            return [0.22, 0.26, 0.34, 0.30, 0.42, 0.50, 0.54, 0.62, 0.70, 0.77, 0.84, 0.90]
        case .all:
            return [0.18, 0.22, 0.28, 0.35, 0.45, 0.53, 0.63, 0.71, 0.81, 0.87, 0.92, 0.96]
        }
    }
}

// MARK: - Dashboard View (1:1 Live Desk Screen from User Request)
struct DashboardView: View {
    @ObservedObject var viewModel: AuthViewModel
    
    @State private var selectedTimeframe: LiveDeskTimeframe = .live
    @State private var livePulse: Bool = false
    @State private var isSharing: Bool = false
    @State private var currentPoints: [CGFloat] = LiveDeskTimeframe.live.curvePoints
    
    // Exact colors from user screenshot
    private let neonGreen = Color(hex: "#00FFA3")
    private let darkBg = Color(hex: "#07090C")
    private let pillBg = Color(hex: "#10141A")
    private let borderDark = Color(hex: "#1A222C")
    
    var body: some View {
        ZStack {
            // Pitch Black Background
            darkBg
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - 1. Top Bar: Live Desk & Share
                HStack {
                    // "Live Desk" Pill
                    HStack(spacing: 7) {
                        Circle()
                            .fill(neonGreen)
                            .frame(width: 8, height: 8)
                            .shadow(color: neonGreen.opacity(0.8), radius: livePulse ? 5 : 2)
                        
                        Text("Live Desk")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(neonGreen)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Color(hex: "#0A1F18"))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(neonGreen.opacity(0.35), lineWidth: 1)
                    )
                    
                    Spacer()
                    
                    // "Share" Pill Button
                    Button(action: {
                        HapticsManager.shared.lightImpact()
                        isSharing = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 12, weight: .semibold))
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
                    
                    // Discreet lock button to test Face ID again
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
                .padding(.horizontal, 20)
                .padding(.top, 56)
                
                // MARK: - 2. Big Balance & PnL Pill Row
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .center, spacing: 12) {
                        // Big Earnings Value
                        Text(selectedTimeframe.earnings)
                            .font(.system(size: 44, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .tracking(0.5)
                        
                        // Green PnL Pill
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
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                }
                
                Spacer()
                
                // MARK: - 3. Neon Green Glowing Chart Line with Gradient Fill
                GeometryReader { chartProxy in
                    let w = chartProxy.size.width
                    let h = chartProxy.size.height
                    let points = currentPoints
                    let lastY = h * (1.0 - (points.last ?? 0.5))
                    let lastX = w
                    
                    ZStack {
                        // Ambient Radiant Glow Underneath Line
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
                        
                        // Main Neon Green Stroke Line
                        LiveDeskChartPath(points: points)
                            .stroke(
                                neonGreen,
                                style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
                            )
                            .shadow(color: neonGreen.opacity(0.7), radius: 6, x: 0, y: 0)
                        
                        // Glowing Tip Dot on Right Edge
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
                .frame(height: 140)
                .padding(.bottom, 24)
                
                // MARK: - 4. Bottom Timeframe Selector: LIVE, 1H, 4H, 1D, 1W, ALL
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
                .padding(.horizontal, 20)
                .padding(.bottom, 48)
            }
        }
        .onAppear {
            // Subtle pulse loop for live indicator
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                livePulse = true
            }
        }
        .sheet(isPresented: $isSharing) {
            ShareSheet(activityItems: ["TradingPL Live Desk: \(selectedTimeframe.earnings) \(selectedTimeframe.changeText)"])
        }
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
