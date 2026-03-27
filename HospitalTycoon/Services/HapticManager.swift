import UIKit

struct HapticManager {
    static let shared = HapticManager()

    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let selection = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()

    private init() {
        // Pre-warm generators
        impactLight.prepare()
        impactMedium.prepare()
        selection.prepare()
        notification.prepare()
    }

    // MARK: - Game Actions

    func buttonTap() {
        impactLight.impactOccurred()
    }

    func buildRoom() {
        impactMedium.impactOccurred()
    }

    func demolishRoom() {
        impactHeavy.impactOccurred()
    }

    func hireStaff() {
        notification.notificationOccurred(.success)
    }

    func fireStaff() {
        notification.notificationOccurred(.warning)
    }

    func installEquipment() {
        impactMedium.impactOccurred()
    }

    func patientArrival() {
        impactLight.impactOccurred()
    }

    func diagnosisConfirmed() {
        notification.notificationOccurred(.success)
    }

    func treatmentComplete() {
        notification.notificationOccurred(.success)
    }

    func claimPaid() {
        impactLight.impactOccurred()
    }

    func claimDenied() {
        notification.notificationOccurred(.error)
    }

    func eventOccurred() {
        notification.notificationOccurred(.warning)
    }

    func selectionChanged() {
        selection.selectionChanged()
    }

    func error() {
        notification.notificationOccurred(.error)
    }

    func success() {
        notification.notificationOccurred(.success)
    }
}
