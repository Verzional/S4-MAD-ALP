//
//  ColorMixingView.swift
//  S4-MAD-ALP
//
//  Created by student on 22/05/25.
//

import SwiftUI

struct ColorMixingView: View {
    @EnvironmentObject var viewModel: ColorMixingViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    
    @State private var selected1: ColorItem?
    @State private var selected2: ColorItem?
    @Namespace private var animationNamespace
    
    var mixedHex: String? {
        guard let s1 = selected1, let s2 = selected2 else { return nil }
        return mixColors(hex1: s1.hex, hex2: s2.hex)
    }
    
    let columns = [
        GridItem(.adaptive(minimum: 80), spacing: 16)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection
            colorGridSection
            mixingControlsSection
        }
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "paintpalette.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                Text("Color Mixing Lab")
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                colorCountBadge
            }
            
            Text("Select two colors to create new combinations")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    private var colorCountBadge: some View {
        HStack(spacing: 4) {
            Text("\(viewModel.unlockedColors.count)")
                .font(.caption)
                .bold()
            Text("colors")
                .font(.caption2)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.1))
        .foregroundColor(.blue)
        .clipShape(Capsule())
    }
    
    // MARK: - Color Grid Section
    private var colorGridSection: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(viewModel.unlockedColors) { color in
                    colorGridItem(for: color)
                }
            }
            .padding(20)
        }
    }
    
    private func colorGridItem(for color: ColorItem) -> some View {
        let isSelected = selected1 == color || selected2 == color
        let selectionNumber = getSelectionNumber(for: color)
        
        return VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color(hex: color.hex))
                    .frame(width: 56, height: 56)
                    .overlay(selectionOverlay(isSelected: isSelected))
                    .shadow(color: isSelected ? Color(hex: color.hex).opacity(0.4) : Color.black.opacity(0.1),
                           radius: isSelected ? 8 : 4, x: 0, y: 2)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                
                if let number = selectionNumber {
                    selectionBadge(number: number)
                }
            }
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    toggleSelection(for: color)
                }
            }
            
            Text(color.hex.uppercased())
                .font(.caption2)
                .foregroundColor(.secondary)
                .monospacedDigit()
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
    }
    
    private func selectionOverlay(isSelected: Bool) -> some View {
        Circle()
            .stroke(Color.white, lineWidth: 3)
            .overlay(
                Circle()
                    .stroke(Color.blue, lineWidth: 2)
            )
            .opacity(isSelected ? 1 : 0)
    }
    
    private func selectionBadge(number: Int) -> some View {
        Circle()
            .fill(Color.blue)
            .frame(width: 20, height: 20)
            .overlay(
                Text("\(number)")
                    .font(.caption2)
                    .bold()
                    .foregroundColor(.white)
            )
            .offset(x: 20, y: -20)
            .transition(.scale.combined(with: .opacity))
    }
    
    private func getSelectionNumber(for color: ColorItem) -> Int? {
        if selected1 == color { return 1 }
        if selected2 == color { return 2 }
        return nil
    }
    
    // MARK: - Mixing Controls Section
    private var mixingControlsSection: some View {
        VStack(spacing: 20) {
            selectedColorsSection
            
            if let mixedHex {
                resultPreviewSection(mixedHex: mixedHex)
            }
            
            mixButton
        }
        .padding(20)
        .background(mixingControlsBackground)
    }
    
    private var mixingControlsBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -2)
    }
    
    private var selectedColorsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                
                Text("Selected Colors")
                    .font(.headline)
                
                Spacer()
                
                if selected1 != nil || selected2 != nil {
                    clearSelectionsButton
                }
            }
            
            HStack(spacing: 20) {
                selectionSlot(color: selected1, slotNumber: 1)
                
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                selectionSlot(color: selected2, slotNumber: 2)
                
                Spacer()
            }
        }
    }
    
    private var clearSelectionsButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                selected1 = nil
                selected2 = nil
            }
        }) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.secondary)
        }
    }
    
    private func selectionSlot(color: ColorItem?, slotNumber: Int) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color != nil ? Color(hex: color!.hex) : Color.gray.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(slotBorder(hasColor: color != nil))
                    .overlay(slotPlaceholder(slotNumber: slotNumber, hasColor: color != nil))
            }
            
            Text(color?.hex.uppercased() ?? "SELECT")
                .font(.caption2)
                .foregroundColor(color != nil ? .primary : .secondary)
                .monospacedDigit()
        }
        .animation(.easeInOut(duration: 0.3), value: color?.id)
    }
    
    private func slotBorder(hasColor: Bool) -> some View {
        Circle()
            .stroke(hasColor ? Color.clear : Color.gray.opacity(0.3),
                   style: StrokeStyle(lineWidth: 2, dash: hasColor ? [] : [5, 5]))
    }
    
    private func slotPlaceholder(slotNumber: Int, hasColor: Bool) -> some View {
        Group {
            if !hasColor {
                Text("\(slotNumber)")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func resultPreviewSection(mixedHex: String) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "flask.fill")
                    .foregroundColor(.purple)
                
                Text("Mixed Result")
                    .font(.headline)
                
                Spacer()
            }
            
            HStack(spacing: 16) {
                Circle()
                    .fill(Color(hex: mixedHex))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                            .shadow(color: Color.black.opacity(0.1), radius: 2)
                    )
                    .shadow(color: Color(hex: mixedHex).opacity(0.4), radius: 8, x: 0, y: 4)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(mixedHex.uppercased())
                        .font(.title3)
                        .bold()
                        .monospacedDigit()
                    
                    Text(viewModel.isColorUnlocked(mixedHex) ? "Already unlocked" : "New color!")
                        .font(.caption)
                        .foregroundColor(viewModel.isColorUnlocked(mixedHex) ? .secondary : .green)
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.purple.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.purple.opacity(0.2), lineWidth: 1)
                )
        )
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    private var mixButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                mixSelectedColors()
                
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: "wand.and.stars")
                    .font(.title3)
                
                Text("Mix Colors")
                    .font(.headline)
                    .bold()
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(mixButtonBackground)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: canMix ? Color.blue.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
            .scaleEffect(canMix ? 1.0 : 0.95)
        }
        .disabled(!canMix)
        .animation(.easeInOut(duration: 0.2), value: canMix)
    }
    
    private var canMix: Bool {
        selected1 != nil && selected2 != nil
    }
    
    private var mixButtonBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(canMix ?
                  LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing) :
                  LinearGradient(colors: [Color.gray, Color.gray], startPoint: .leading, endPoint: .trailing)
            )
    }
    
    // MARK: - Helper Functions
    private func toggleSelection(for color: ColorItem) {
        if selected1 == color {
            selected1 = nil
        } else if selected2 == color {
            selected2 = nil
        } else if selected1 == nil {
            selected1 = color
        } else if selected2 == nil {
            selected2 = color
        }
    }
    
    private func mixSelectedColors() {
        guard let color1 = selected1, let color2 = selected2 else { return }
        
        let newHex = mixColors(hex1: color1.hex, hex2: color2.hex)
        
        if !viewModel.isColorUnlocked(newHex) {
            let newColor = ColorItem(id: UUID(), name: "Mixed", hex: newHex)
            viewModel.addNewColor(newColor)
            userViewModel.gainXP(xp: 10)
        }
        
        selected1 = nil
        selected2 = nil
    }
}
