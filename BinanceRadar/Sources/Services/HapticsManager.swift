import UIKit

// MARK: - Haptic Feedback Manager (iPhone Taptic Engine)
final class HapticsManager {
    static let shared = HapticsManager()
    
    private init() {}
    
    // Light tap for tabs and toggles
    func lightImpact() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    func light() {
        lightImpact()
    }
    
    // Medium tap for buttons
    func mediumImpact() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    func medium() {
        mediumImpact()
    }
    
    // Rigid/heavy tap for biometric scan start
    func rigidImpact() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare()
        generator.impactOccurred()
    }
    func rigid() {
        rigidImpact()
    }
    
    // Success feedback when Face ID recognizes user
    func notifySuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    func success() {
        notifySuccess()
    }
    
    // Error feedback when face does not match or password wrong
    func notifyError() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }
    func error() {
        notifyError()
    }
}
