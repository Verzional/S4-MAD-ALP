//
//  ColorPickerSheetView.swift
//  S4-MAD-ALP
//
//  Created by student on 03/06/25.
//

import SwiftUI

struct ColorPickerSheetView: View {
    @EnvironmentObject var viewModel: ColorMixingViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @Environment(\.dismiss) var dismiss
    

    @State private var searchText: String = ""
    
    var onColorSelect: (ColorItem) -> Void

    private var filteredColors: [ColorItem] {
        if searchText.isEmpty {
            return userViewModel.unlockedColors
        } else {
            return userViewModel.unlockedColors.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    let columns = [
        GridItem(.adaptive(minimum: 80), spacing: 16)
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search by color name...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .autocorrectionDisabled()
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top)
                .padding(.bottom, 8)

                if filteredColors.isEmpty {
                    VStack {
                        Spacer()
                        Image(systemName: "paintpalette.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.7))
                            .padding(.bottom, 5)
                        Text(searchText.isEmpty ? "No Colors Unlocked Yet" : "No colors found for \"\(searchText)\"")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(filteredColors) { color in
                                colorGridItem(for: color)
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("Select a Color")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
        }
    }

    private func colorGridItem(for color: ColorItem) -> some View {
        Button(action: {
            onColorSelect(color)
            dismiss()
        }) {
            VStack(spacing: 8) {
                Circle()
                    .fill(Color(hex: color.hex))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 3, y: 1)
                
                Text(color.name)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(height: 30)
            }
            .padding(5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview("Color Picker Sheet") {
    struct PreviewContainer: View {
        @StateObject var mockViewModel = ColorMixingViewModel()
        @StateObject var mockUserViewModel = UserViewModel()
        
        init() {
            mockUserViewModel.unlockedColors = [
                ColorItem(id: UUID(), name: "Fiery Red", hex: "#FF0000"),
                ColorItem(id: UUID(), name: "Ocean Blue", hex: "#0000FF"),
                ColorItem(id: UUID(), name: "Forest Green", hex: "#008000"),
                ColorItem(id: UUID(), name: "Sunny Yellow", hex: "#FFFF00"),
                ColorItem(id: UUID(), name: "Purple Dream", hex: "#800080"),
                ColorItem(id: UUID(), name: "Orange Burst", hex: "#FFA500"),
                ColorItem(id: UUID(), name: "Pink Delight", hex: "#FFC0CB"),
                ColorItem(id: UUID(), name: "Teal Magic", hex: "#008080")
            ]
        }
        
        var body: some View {
            ColorPickerSheetView(onColorSelect: { selectedColor in
                print("Preview: Selected color \(selectedColor.name)")
            })
            .environmentObject(mockViewModel)
            .environmentObject(mockUserViewModel)
        }
    }
    
    return PreviewContainer()
}

#Preview("Color Picker Sheet (Empty)") {
    struct PreviewContainerEmpty: View {
        @StateObject var mockViewModel = ColorMixingViewModel()
        @StateObject var mockUserViewModel = UserViewModel()
        
        var body: some View {
            ColorPickerSheetView(onColorSelect: { selectedColor in
                print("Preview: Selected color \(selectedColor.name)")
            })
            .environmentObject(mockViewModel)
            .environmentObject(mockUserViewModel) 
        }
    }
    
    return PreviewContainerEmpty()
}
