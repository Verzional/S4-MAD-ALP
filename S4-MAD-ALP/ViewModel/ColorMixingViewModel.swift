//
//  ColorInventoryViewModel.swift
//  S4-MAD-ALP
//
//  Created by student on 22/05/25.
//

import Foundation

class ColorMixingViewModel: ObservableObject {
    @Published var unlockedColors: [ColorItem] = []

    init() {
        loadInitialColors()
    }

    func loadInitialColors() {
        unlockedColors = [
            ColorItem(id: UUID(), name: "White", hex: "#FFFFFF"),
            ColorItem(id: UUID(), name: "Black", hex: "#000000"),
            ColorItem(id: UUID(), name: "Red", hex: "#FF0000"),
            ColorItem(id: UUID(), name: "Green", hex: "#00FF00"),
            ColorItem(id: UUID(), name: "Blue", hex: "#0000FF"),
            ColorItem(id: UUID(), name: "Yellow", hex: "#FFFF00"),
            ColorItem(id: UUID(), name: "Magenta", hex: "#FF00FF"),
            ColorItem(id: UUID(), name: "Cyan", hex: "#00FFFF")
        ]
    }

    func addNewColor(_ color: ColorItem) {
        guard !unlockedColors.contains(where: { $0.hex.lowercased() == color.hex.lowercased() }) else { return }
        unlockedColors.append(color)
    }

    func isColorUnlocked(_ hex: String) -> Bool {
        unlockedColors.contains(where: { $0.hex.lowercased() == hex.lowercased() })
    }
}
