//
//  ColorNamingSheetView.swift
//  S4-MAD-ALP
//
//  Created by student on 03/06/25.
//

import SwiftUI

struct ColorNamingSheetView: View {
    @Environment(\.dismiss) var dismiss

    @Binding var newColorName: String
    let pendingNewHex: String?

    var onSave: (String) -> Void
    var onCancel: () -> Void

    private var saveButtonEnabled: Bool {
        !newColorName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Congratulations! 🎉")
                    .font(.title2)
                Text("You've discovered a new color!")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 10)

                if let hex = pendingNewHex, !hex.isEmpty {
                    Circle()
                        .fill(Color(hex: hex))
                        .frame(width: 80, height: 80)
                        .overlay(Circle().stroke(Color.primary.opacity(0.2), lineWidth: 1))
                        .shadow(color: Color(hex: hex).opacity(0.5), radius: 8, y: 4)
                        .padding(.bottom, 5)
                    
                    Text(hex.uppercased())
                        .font(.custom("Menlo", size: 14))
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "questionmark")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                        )
                        .padding(.bottom, 5)
                    Text("Mixing Took Too Long, Please Try Again")
                        .font(.custom("Menlo", size: 14))
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                }

                TextField("Enter color name", text: $newColorName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 40)
                    .multilineTextAlignment(.center)
                    .submitLabel(.done)

                Button(action: {
                    let finalName = newColorName.trimmingCharacters(in: .whitespacesAndNewlines)
                    onSave(finalName)
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

                Spacer()
            }
            .padding(.top, 30)
            .navigationTitle("Name Your Color")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
            }
        }
    }
}

// Updated Preview Section
#Preview("With Valid Hex") {
    // Helper struct to manage @State for the preview
    struct PreviewContainer: View {
        @State var colorName: String = "My Awesome Color"
        let hex: String?
        
        var body: some View {
            ColorNamingSheetView(
                newColorName: $colorName,
                pendingNewHex: hex,
                onSave: { name in print("Preview Save: \(name)") },
                onCancel: { print("Preview Cancel") }
            )
        }
    }
    return PreviewContainer(hex: "#A1B2C3")
}

#Preview("With Nil Hex") {
    struct PreviewContainer: View {
        @State var colorName: String = "My Awesome Color"
        let hex: String?
        
        var body: some View {
            ColorNamingSheetView(
                newColorName: $colorName,
                pendingNewHex: hex,
                onSave: { name in print("Preview Save: \(name)") },
                onCancel: { print("Preview Cancel") }
            )
        }
    }
    return PreviewContainer(hex: nil)
}

#Preview("With Empty Hex") {
    struct PreviewContainer: View {
        @State var colorName: String = "My Awesome Color"
        let hex: String?
        
        var body: some View {
            ColorNamingSheetView(
                newColorName: $colorName,
                pendingNewHex: hex,
                onSave: { name in print("Preview Save: \(name)") },
                onCancel: { print("Preview Cancel") }
            )
        }
    }
    return PreviewContainer(hex: "")
}
