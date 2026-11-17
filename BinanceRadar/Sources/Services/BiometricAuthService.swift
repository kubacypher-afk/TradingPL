import Foundation
import LocalAuthentication

// MARK: - Biometric Error Types
enum BiometricError: LocalizedError {
    case notAvailable
    case canceled
    case failed
    case lockout
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "Funkcja Face ID nie jest skonfigurowana lub dostępna na tym urządzeniu."
        case .canceled:
            return "Autoryzacja Face ID została anulowana."
        case .failed:
            return "Nie rozpoznano twarzy. Spróbuj ponownie lub użyj hasła."
        case .lockout:
            return "Zbyt wiele nieudanych prób Face ID. Zablokowano biometrię."
        case .unknown(let msg):
            return msg
        }
    }
}

// MARK: - Hardware Biometric Authentication Service (Apple LocalAuthentication)
@MainActor
final class BiometricAuthService {
    static let shared = BiometricAuthService()
    
    private init() {}
    
    // Checks if iPhone hardware supports Face ID
    var isBiometricsAvailable: Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    // Returns "Face ID" or "Touch ID"
    var biometricTypeString: String {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch context.biometryType {
            case .faceID:
                return "Face ID"
            case .touchID:
                return "Touch ID"
            case .opticID:
                return "Optic ID"
            default:
                return "Biometria"
            }
        }
        return "Biometria"
    }
    
    // Evaluates real hardware Face ID policy on iPhone
    func authenticate(reason: String = "Zaloguj się do Binance Radar za pomocą Face ID") async -> Result<Bool, BiometricError> {
        let context = LAContext()
        context.localizedCancelTitle = "Anuluj"
        
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .failure(.notAvailable)
        }
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            
            if success {
                HapticsManager.shared.notifySuccess()
                return .success(true)
            } else {
                HapticsManager.shared.notifyError()
                return .failure(.failed)
            }
        } catch let laError as LAError {
            HapticsManager.shared.notifyError()
            switch laError.code {
            case .userCancel, .appCancel:
                return .failure(.canceled)
            case .biometryNotAvailable:
                return .failure(.notAvailable)
            case .biometryLockout:
                return .failure(.lockout)
            default:
                return .failure(.failed)
            }
        } catch {
            HapticsManager.shared.notifyError()
            return .failure(.unknown(error.localizedDescription))
        }
    }
}
