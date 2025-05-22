//
//  CanvasView.swift
//  S4-MAD-ALP
//
//  Created by student on 22/05/25.
//

import SwiftUI

struct CanvasView: View {
    @EnvironmentObject var cvm: CanvasViewModel
    @EnvironmentObject var cmvm: ColorMixingViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            canvasSection
            colorPaletteSection
            brushSizeSection
        }
        .padding(16)
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Canvas Section
    private var canvasSection: some View {
        GeometryReader { geo in
            Canvas { context, size in
                for stroke in cvm.strokes {
                    drawStroke(stroke, context: context)
                }
                
                if let stroke = cvm.currentStroke {
                    drawStroke(stroke, context: context, isCurrent: true)
                }
            }
            .gesture(drawingGesture)
        }
        .background(canvasBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(canvasBorder)
    }
    
    private var canvasBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.white)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private var canvasBorder: some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
    }
    
    // MARK: - Color Palette Section
    private var colorPaletteSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            colorPaletteHeader
            colorScrollView
        }
        .padding(16)
        .background(sectionBackground)
    }
    
    private var colorPaletteHeader: some View {
        HStack {
            Text("Colors")
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            currentColorIndicator
        }
    }
    
    private var currentColorIndicator: some View {
        HStack(spacing: 8) {
            Text("Current:")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Circle()
                .fill(cvm.strokeColor)
                .frame(width: 20, height: 20)
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.3), lineWidth: 1)
                )
        }
    }
    
    private var colorScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(cmvm.unlockedColors) { item in
                    colorCircle(for: item)
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
        }
    }
    
    private func colorCircle(for item: ColorItem) -> some View {
        let color = Color(hex: item.hex)
        let isSelected = cvm.strokeColor == color
        
        return Circle()
            .fill(color)
            .frame(width: isSelected ? 40 : 35, height: isSelected ? 40 : 35)
            .overlay(selectedColorOverlay(isSelected: isSelected))
            .overlay(colorCircleBorder(isSelected: isSelected))
            .scaleEffect(isSelected ? 1.1 : 1.0)
            .shadow(color: isSelected ? color.opacity(0.4) : Color.clear, radius: 8, x: 0, y: 4)
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    cvm.strokeColor = color
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
    
    private func selectedColorOverlay(isSelected: Bool) -> some View {
        Circle()
            .stroke(Color.white, lineWidth: 3)
            .opacity(isSelected ? 1 : 0)
    }
    
    private func colorCircleBorder(isSelected: Bool) -> some View {
        Circle()
            .stroke(Color.black.opacity(0.3), lineWidth: isSelected ? 2 : 1)
    }
    
    // MARK: - Brush Size Section
    private var brushSizeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            brushSizeHeader
            brushSizeSlider
        }
        .padding(16)
        .background(sectionBackground)
    }
    
    private var brushSizeHeader: some View {
        HStack {
            Text("Brush Size")
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            brushSizeIndicator
        }
    }
    
    private var brushSizeIndicator: some View {
        HStack(spacing: 8) {
            Text("\(Int(cvm.strokeWidth))pt")
                .font(.caption)
                .foregroundColor(.secondary)
                .monospacedDigit()
            
            Circle()
                .fill(cvm.strokeColor)
                .frame(
                    width: min(cvm.strokeWidth * 1.5, 25),
                    height: min(cvm.strokeWidth * 1.5, 25)
                )
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.3), lineWidth: 0.5)
                )
        }
    }
    
    private var brushSizeSlider: some View {
        HStack(spacing: 16) {
            minSizeIndicator
            
            Slider(value: $cvm.strokeWidth, in: 1...20, step: 1) {
                Text("Brush Size")
            }
            .tint(cvm.strokeColor)
            
            maxSizeIndicator
        }
    }
    
    private var minSizeIndicator: some View {
        Circle()
            .fill(Color.gray.opacity(0.4))
            .frame(width: 4, height: 4)
    }
    
    private var maxSizeIndicator: some View {
        Circle()
            .fill(Color.gray.opacity(0.4))
            .frame(width: 16, height: 16)
    }
    
    private var sectionBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
    }
    
    // MARK: - Drawing Functions
    private func drawStroke(_ stroke: Stroke, context: GraphicsContext, isCurrent: Bool = false) {
        var path = Path()
        guard let firstPoint = stroke.points.first else { return }
        path.move(to: firstPoint)
        for point in stroke.points.dropFirst() {
            path.addLine(to: point)
        }
        
        if isCurrent {
            context.stroke(path, with: .color(stroke.color.opacity(0.3)), lineWidth: stroke.lineWidth + 2)
        }
        
        context.stroke(path, with: .color(stroke.color), lineWidth: stroke.lineWidth)
    }
    
    private var drawingGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if cvm.currentStroke == nil {
                    cvm.startStroke(at: value.location)
                } else {
                    cvm.addPoint(value.location)
                }
            }
            .onEnded { _ in
                cvm.endStroke()
            }
    }
}
