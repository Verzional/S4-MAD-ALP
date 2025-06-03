//
//  ColorNamingSheetView.swift
//  S4-MAD-ALP
//
//  Created by student on 03/06/25.
//

import SwiftUI

struct ColorNamingSheetView: View {
    // MARK: - Environment and State Bindings
    @Environment(\.dismiss) var dismiss // To programmatically dismiss the sheet

    @Binding var newColorName: String // Two-way binding for the text field
    let pendingNewHex: String? // The hex code of the color to be named

    // MARK: - Actions
    var onSave: (String) -> Void // Closure to call when saving
    var onCancel: () -> Void // Closure to call when cancelling

    // MARK: - Computed Properties
    private var saveButtonEnabled: Bool {
        !newColorName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // MARK: - Header
                Text("Congratulations! 🎉")
                    .font(.title2)
                Text("You've discovered a new color!")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 10)

                // MARK: - Color Preview
                if let hex = pendingNewHex {
                    Circle()
                        .fill(Color(hex: hex))
                        .frame(width: 80, height: 80)
                        .overlay(Circle().stroke(Color.primary.opacity(0.2), lineWidth: 1))
                        .shadow(color: Color(hex: hex).opacity(0.5), radius: 8, y: 4)
                        .padding(.bottom, 5)
                    
                    Text(hex.uppercased())
                        .font(.custom("Menlo", size: 14)) // Monospaced font for hex
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                }

                // MARK: - Name Input Field
                TextField("Enter color name", text: $newColorName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 40)
                    .multilineTextAlignment(.center)
                    .submitLabel(.done) // Changes the return key to "Done"

                // MARK: - Save Button
                Button(action: {
                    let finalName = newColorName.trimmingCharacters(in: .whitespacesAndNewlines)
                    onSave(finalName) // Call the onSave closure
                    // Dismissal is handled by the parent view after onSave completes
                }) {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Save New Color")
                            .bold()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(saveButtonEnabled ? Color.blue : Color.gray.opacity(0.5))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }
                .disabled(!saveButtonEnabled)
                .padding(.horizontal, 40)
                .animation(.easeInOut, value: saveButtonEnabled)

                Spacer() // Pushes content to the top
            }
            .padding(.top, 30) // Padding for the content inside VStack
            .navigationTitle("Name Your Color")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // MARK: - Cancel Button in Toolbar
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        onCancel() // Call the onCancel closure
                        // Dismissal is handled by the parent view
                    }
                }
            }
            // Optional: Apply an overall background to the sheet content
            // .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
    }
}

// MARK: - Preview
struct ColorNamingSheetView_Previews: PreviewProvider {
    static var previews: some View {
        // Example of how to use bindings in a preview
        // State variables are needed in the preview provider to hold the binding's source of truth
        @State var previewNewColorName: String = "My Awesome Color"
        let previewPendingHex: String? = "#A1B2C3"
        
        ColorNamingSheetView(
            newColorName: $previewNewColorName,
            pendingNewHex: previewPendingHex,
            onSave: { name in print("Preview Save: \(name)") },
            onCancel: { print("Preview Cancel") }
        )
        .environmentObject(ColorMixingViewModel()) // If your sheet uses environment objects directly
        .environmentObject(UserViewModel())
    }
}