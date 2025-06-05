//
//  CanvasViewModel.swift
//  S4-MAD-ALP
//
//  Created by student on 22/05/25.
//

import Foundation
import SwiftUI

class CanvasViewModel: ObservableObject {
    @Published var strokes: [Stroke] = []
    @Published var currentStroke: Stroke? = nil
    @Published var strokeColor: Color = .black
    @Published var strokeWidth: CGFloat = 5

    func startStroke(at point: CGPoint) {
        currentStroke = Stroke(points: [point], color: strokeColor, lineWidth: strokeWidth)
    }

    func addPoint(_ point: CGPoint) {
        currentStroke?.points.append(point)
    }

    func endStroke() {
        if let stroke = currentStroke {
            strokes.append(stroke)
            currentStroke = nil
        }
    }

    func changeColor(to color: Color) {
        strokeColor = color
    }

    func changeLineWidth(to width: CGFloat) {
        strokeWidth = width
    }
    
    
}
