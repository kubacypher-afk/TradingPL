import SwiftUI

// MARK: - Crypto City Map Node Model
struct CryptoCityNode: Identifiable {
    let id: String
    let symbol: String
    let name: String
    let price: String
    let change: String
    let isPositive: Bool
    let color: Color
    let xPercent: CGFloat
    let yPercent: CGFloat
    let district: String
}

// MARK: - Connection Line Model
struct CryptoCityConnection: Identifiable {
    let id: String
    let fromSymbol: String
    let toSymbol: String
    let color: Color
}

// MARK: - Crypto City Map Intro View
struct CryptoCityMapView: View {
    let onFinished: () -> Void
    
    // Nodes across the city grid
    private let nodes: [CryptoCityNode] = [
        CryptoCityNode(id: "BTC", symbol: "BTC", name: "Bitcoin Citadel", price: "$96,420", change: "+5.4%", isPositive: true, color: Color(hex: "#F7931A"), xPercent: 0.48, yPercent: 0.26, district: "Alpha Core"),
        CryptoCityNode(id: "ETH", symbol: "ETH", name: "Ethereum Nexus", price: "$3,340", change: "+3.8%", isPositive: true, color: Color(hex: "#627EEA"), xPercent: 0.78, yPercent: 0.38, district: "DeFi Wharf"),
        CryptoCityNode(id: "SOL", symbol: "SOL", name: "Solana Boulevard", price: "$218", change: "+11.2%", isPositive: true, color: Color(hex: "#14F195"), xPercent: 0.20, yPercent: 0.42, district: "High-Freq Ave"),
        CryptoCityNode(id: "BNB", symbol: "BNB", name: "Binance Plaza", price: "$652", change: "+4.1%", isPositive: true, color: Color.binanceYellow, xPercent: 0.50, yPercent: 0.52, district: "Liquidity Hub"),
        CryptoCityNode(id: "XRP", symbol: "XRP", name: "Ripple Corridor", price: "$1.45", change: "+18.9%", isPositive: true, color: Color(hex: "#23292F"), xPercent: 0.82, yPercent: 0.68, district: "Cross-Border Bay"),
        CryptoCityNode(id: "DOGE", symbol: "DOGE", name: "Meme Square", price: "$0.38", change: "+8.4%", isPositive: true, color: Color(hex: "#C2A633"), xPercent: 0.24, yPercent: 0.72, district: "Meme Sector"),
        CryptoCityNode(id: "AVAX", symbol: "AVAX", name: "Subnet Hills", price: "$35.2", change: "+6.7%", isPositive: true, color: Color(hex: "#E84142"), xPercent: 0.52, yPercent: 0.80, district: "Snow Avalanche")
    ]
    
    // Inter-node connection network
    private let connections: [CryptoCityConnection] = [
        CryptoCityConnection(id: "c1", fromSymbol: "BTC", toSymbol: "BNB", color: Color.binanceYellow),
        CryptoCityConnection(id: "c2", fromSymbol: "ETH", toSymbol: "BNB", color: Color(hex: "#627EEA")),
        CryptoCityConnection(id: "c3", fromSymbol: "SOL", toSymbol: "BNB", color: Color(hex: "#14F195")),
        CryptoCityConnection(id: "c4", fromSymbol: "BTC", toSymbol: "ETH", color: Color(hex: "#F7931A")),
        CryptoCityConnection(id: "c5", fromSymbol: "SOL", toSymbol: "DOGE", color: Color(hex: "#14F195")),
        CryptoCityConnection(id: "c6", fromSymbol: "BNB", toSymbol: "XRP", color: Color.binanceYellow),
        CryptoCityConnection(id: "c7", fromSymbol: "BNB", toSymbol: "AVAX", color: Color(hex: "#E84142")),
        CryptoCityConnection(id: "c8", fromSymbol: "XRP", toSymbol: "AVAX", color: Color(hex: "#23292F"))
    ]
    
    // Animation states
    @State private var mapLoaded: Bool = false
    @State private var radarRotation: Double = 0
    @State private var radarRings: Bool = false
    @State private var visibleNodes: Set<String> = []
    @State private var lineProgress: CGFloat = 0.0
    @State private var pulsesActive: Bool = false
    @State private var isConverging: Bool = false
    @State private var shockwave: Bool = false
    @State private var statusText: String = "SKANOWANIE SIECI MIEJSKIEJ..."
    @State private var timerSubscription: Timer?
    
    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            
            ZStack {
                // Deep dark background
                Color.binanceBg
                    .ignoresSafeArea()
                
                // MARK: - 1. City Cartography Vector Grid (Streets & Blocks)
                ZStack {
                    // Street Grid Matrix
                    CityStreetsGrid(width: w, height: h)
                        .stroke(Color.binanceLine.opacity(0.4), lineWidth: 1)
                    
                    // Main Arterial Highways
                    CityArteries(width: w, height: h)
                        .stroke(Color.binanceGold.opacity(0.18), lineWidth: 2)
                    
                    // Radar circular scan line sweep
                    Circle()
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [
                                    Color.binanceYellow.opacity(0.35),
                                    Color.binanceYellow.opacity(0.0),
                                    Color.clear
                                ]),
                                center: .center
                            ),
                            lineWidth: min(w, h) * 0.7
                        )
                        .frame(width: min(w, h) * 1.4, height: min(w, h) * 1.4)
                        .rotationEffect(.degrees(radarRotation))
                        .blendMode(.screen)
                }
                .rotation3DEffect(
                    .degrees(isConverging ? 0 : 22),
                    axis: (x: 1.0, y: 0.0, z: 0.0),
                    perspective: 0.6
                )
                .scaleEffect(isConverging ? 1.45 : (mapLoaded ? 1.0 : 0.85))
                .opacity(mapLoaded ? 1.0 : 0.0)
                
                // MARK: - 2. Animated Connection Lines
                ForEach(connections) { conn in
                    if let fromNode = node(for: conn.fromSymbol),
                       let toNode = node(for: conn.toSymbol) {
                        let p1 = CGPoint(x: fromNode.xPercent * w, y: fromNode.yPercent * h)
                        let p2 = CGPoint(x: toNode.xPercent * w, y: toNode.yPercent * h)
                        
                        ConnectionPath(from: p1, to: p2)
                            .trim(from: 0, to: lineProgress)
                            .stroke(
                                LinearGradient(
                                    colors: [conn.color.opacity(0.9), Color.binanceYellow.opacity(0.9)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [4, 2])
                            )
                            .shadow(color: conn.color.opacity(0.6), radius: 6, x: 0, y: 0)
                    }
                }
                
                // MARK: - 3. Crypto Pins / City Nodes
                ForEach(nodes) { item in
                    let x = item.xPercent * w
                    let y = item.yPercent * h
                    
                    if visibleNodes.contains(item.symbol) {
                        CryptoPinView(node: item, isPulsing: radarRings)
                            .position(x: x, y: y)
                            .transition(.scale(scale: 0.1).combined(with: .opacity))
                    }
                }
                
                // MARK: - 4. Central Binance Convergence Shockwave
                if shockwave {
                    Circle()
                        .stroke(Color.binanceYellow, lineWidth: 3)
                        .frame(width: 120, height: 120)
                        .scaleEffect(3.8)
                        .opacity(0.0)
                        .animation(.easeOut(duration: 0.75), value: shockwave)
                }
                
                // Central Binance Diamond during convergence
                if isConverging {
                    VStack(spacing: 16) {
                        BinanceDiamondLogo(size: 80)
                            .shadow(color: Color.binanceYellow.opacity(0.8), radius: 24)
                            .scaleEffect(shockwave ? 1.15 : 0.8)
                        
                        Text("BINANCE RADAR")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .tracking(2.5)
                        
                        Text("POŁĄCZONO Z SIECIĄ KRYPTO")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color.binanceYellow)
                            .tracking(1.5)
                    }
                    .transition(.scale(scale: 0.6).combined(with: .opacity))
                }
                
                // MARK: - 5. HUD Overlay (Status Bar & Skip Button)
                VStack {
                    HStack {
                        // Live Radar telemetry badge
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.binanceGreen)
                                .frame(width: 7, height: 7)
                                .scaleEffect(radarRings ? 1.3 : 0.8)
                            
                            Text(statusText)
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Color.binanceCard.opacity(0.85))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(Color.binanceLine, lineWidth: 1)
                        )
                        
                        Spacer()
                        
                        // Skip / Pomiń Button
                        Button(action: {
                            HapticsManager.shared.lightImpact()
                            finishIntro()
                        }) {
                            Text("Pomiń")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color.binanceSubtext)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(Color.binanceCard.opacity(0.7))
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.top, 54)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // City Coordinates Pill
                    HStack(spacing: 16) {
                        Label("WARSZAWA // RADAR HUB", systemImage: "location.fill")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.binanceSubtext)
                        
                        Spacer()
                        
                        Text("120 FPS NATIVE")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundColor(Color.binanceGreen)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)
                }
                .opacity(isConverging ? 0.0 : 1.0)
            }
        }
        .onAppear {
            startAnimationSequence()
        }
    }
    
    // Helper to find node by symbol
    private func node(for symbol: String) -> CryptoCityNode? {
        nodes.first { $0.symbol == symbol }
    }
    
    // MARK: - Orchestrated Animation Sequence
    private func startAnimationSequence() {
        // Step 1: Map appearance
        withAnimation(.easeOut(duration: 0.8)) {
            mapLoaded = true
        }
        
        // Continuous radar spin
        withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
            radarRotation = 360
        }
        
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            radarRings = true
        }
        
        // Step 2: Sequentially drop crypto pins on the map
        for (index, node) in nodes.enumerated() {
            let delaySeconds = 0.35 + (Double(index) * 0.16)
            let symbolKey = node.symbol
            DispatchQueue.main.asyncAfter(deadline: .now() + delaySeconds) {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.65)) {
                    _ = self.visibleNodes.insert(symbolKey)
                }
                HapticsManager.shared.lightImpact()
            }
        }
        
        // Step 3: Draw interconnecting liquidity lasers
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            self.statusText = "SYNCHRONIZACJA WĘZŁÓW..."
            HapticsManager.shared.mediumImpact()
            
            withAnimation(.easeInOut(duration: 1.2)) {
                self.lineProgress = 1.0
            }
        }
        
        // Step 4: Full Convergence into Binance Diamond Core
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.1) {
            self.statusText = "AUTORYZACJA TERMINALA..."
            HapticsManager.shared.rigidImpact()
            
            withAnimation(.spring(response: 0.65, dampingFraction: 0.72)) {
                self.isConverging = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.shockwave = true
                HapticsManager.shared.notifySuccess()
            }
        }
        
        // Step 5: Transition into Auth (Login / Register) Screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.3) {
            finishIntro()
        }
    }
    
    private func finishIntro() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) {
            onFinished()
        }
    }
}

// MARK: - Crypto Pin View (Map Marker)
struct CryptoPinView: View {
    let node: CryptoCityNode
    let isPulsing: Bool
    
    var body: some View {
        VStack(spacing: 3) {
            // Price pill
            HStack(spacing: 3) {
                Text(node.symbol)
                    .font(.system(size: 9, weight: .black))
                    .foregroundColor(.white)
                Text(node.change)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(node.isPositive ? Color.binanceGreen : Color.binanceRed)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Color.binanceCard.opacity(0.92))
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(node.color.opacity(0.7), lineWidth: 1)
            )
            .shadow(color: node.color.opacity(0.4), radius: 6)
            
            // Marker Pin Icon with Radar Ripple
            ZStack {
                // Expanding radar pulse
                Circle()
                    .stroke(node.color.opacity(0.4), lineWidth: 1.5)
                    .frame(width: isPulsing ? 38 : 18, height: isPulsing ? 38 : 18)
                    .opacity(isPulsing ? 0.0 : 0.8)
                
                // Pin Halo
                Circle()
                    .fill(node.color.opacity(0.25))
                    .frame(width: 26, height: 26)
                
                // Central Core
                Circle()
                    .fill(node.color)
                    .frame(width: 14, height: 14)
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.8), lineWidth: 1.5)
                    )
            }
            
            // District label
            Text(node.district)
                .font(.system(size: 7, weight: .medium))
                .foregroundColor(Color.binanceSubtext)
        }
    }
}

// MARK: - Connection Path (Bezier Link)
struct ConnectionPath: Shape {
    let from: CGPoint
    let to: CGPoint
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: from)
        
        // Gentle curve between points
        let midX = (from.x + to.x) / 2
        let midY = (from.y + to.y) / 2
        let control = CGPoint(x: midX, y: midY - 20)
        
        path.addQuadCurve(to: to, control: control)
        return path
    }
}

// MARK: - City Streets Grid (Background Map Layer)
struct CityStreetsGrid: Shape {
    let width: CGFloat
    let height: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Horizontal street lines
        let hStep = height / 14
        for i in 0...14 {
            let y = CGFloat(i) * hStep
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: width, y: y))
        }
        
        // Vertical street lines
        let wStep = width / 10
        for j in 0...10 {
            let x = CGFloat(j) * wStep
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: height))
        }
        
        return path
    }
}

// MARK: - City Main Arteries (Diagonal Expressways)
struct CityArteries: Shape {
    let width: CGFloat
    let height: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Highway 1: Northwest to Southeast
        path.move(to: CGPoint(x: 0, y: height * 0.15))
        path.addCurve(
            to: CGPoint(x: width, y: height * 0.85),
            control1: CGPoint(x: width * 0.3, y: height * 0.4),
            control2: CGPoint(x: width * 0.7, y: height * 0.6)
        )
        
        // Highway 2: Southwest to Northeast
        path.move(to: CGPoint(x: 0, y: height * 0.75))
        path.addCurve(
            to: CGPoint(x: width, y: height * 0.25),
            control1: CGPoint(x: width * 0.4, y: height * 0.7),
            control2: CGPoint(x: width * 0.6, y: height * 0.3)
        )
        
        return path
    }
}
