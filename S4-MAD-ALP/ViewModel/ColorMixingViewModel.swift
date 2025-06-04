import Foundation
import SwiftUI

@MainActor
class ColorMixingViewModel: ObservableObject {
    func addNewColor(_ color: ColorItem, to userViewModel: UserViewModel) {
        guard !userViewModel.unlockedColors.contains(where: { $0.hex.lowercased() == color.hex.lowercased() }) else { return }
        userViewModel.unlockedColors.append(color)
        Task {
            await userViewModel.saveColorsToFirebase()
        }
    }

    func isColorUnlocked(_ hex: String, from userViewModel: UserViewModel) -> Bool {
        userViewModel.unlockedColors.contains(where: { $0.hex.lowercased() == hex.lowercased() })
    }
}
