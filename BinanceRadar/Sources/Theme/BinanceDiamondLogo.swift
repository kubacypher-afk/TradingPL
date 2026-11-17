import SwiftUI

// MARK: - Binance Geometric Diamond Logo (Vector SwiftUI)
struct BinanceDiamondLogo: View {
    var size: CGFloat = 40
    var color: Color = .binanceYellow
    
    var body: some View {
        ZStack {
            // Background glow on hover/active
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: size * 1.5, height: size * 1.5)
                .blur(radius: size * 0.2)
            
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let midX = w / 2
                let midY = h / 2
                let s = min(w, h)
                
                // Center diamond
                PolygonShape(points: [
                    CGPoint(x: midX, y: midY - s * 0.16),
                    CGPoint(x: midX + s * 0.16, y: midY),
                    CGPoint(x: midX, y: midY + s * 0.16),
                    CGPoint(x: midX - s * 0.16, y: midY)
                ])
                .fill(color)
                
                // Top Diamond
                PolygonShape(points: [
                    CGPoint(x: midX, y: midY - s * 0.48),
                    CGPoint(x: midX + s * 0.12, y: midY - s * 0.36),
                    CGPoint(x: midX, y: midY - s * 0.24),
                    CGPoint(x: midX - s * 0.12, y: midY - s * 0.36)
                ])
                .fill(color)
                
                // Bottom Diamond
                PolygonShape(points: [
                    CGPoint(x: midX, y: midY + s * 0.48),
                    CGPoint(x: midX + s * 0.12, y: midY + s * 0.36),
                    CGPoint(x: midX, y: midY + s * 0.24),
                    CGPoint(x: midX - s * 0.12, y: midY + s * 0.36)
                ])
                .fill(color)
                
                // Left Wing
                PolygonShape(points: [
                    CGPoint(x: midX - s * 0.48, y: midY),
                    CGPoint(x: midX - s * 0.36, y: midY - s * 0.12),
                    CGPoint(x: midX - s * 0.24, y: midY),
                    CGPoint(x: midX - s * 0.36, y: midY + s * 0.12)
                ])
                .fill(color)
                
                // Right Wing
                PolygonShape(points: [
                    CGPoint(x: midX + s * 0.48, y: midY),
                    CGPoint(x: midX + s * 0.36, y: midY - s * 0.12),
                    CGPoint(x: midX + s * 0.24, y: midY),
                    CGPoint(x: midX + s * 0.36, y: midY + s * 0.12)
                ])
                .fill(color)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Generic Polygon Shape for SwiftUI
struct PolygonShape: Shape {
    let points: [CGPoint]
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard points.count > 1 else { return path }
        
        path.move(to: points[0])
        for index in 1..<points.count {
            path.addLine(to: points[index])
        }
        path.closeSubpath()
        return path
    }
}
