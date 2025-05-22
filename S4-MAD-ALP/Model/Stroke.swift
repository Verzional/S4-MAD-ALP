//
//  Stroke 2.swift
//  S4-MAD-ALP
//
//  Created by student on 22/05/25.
//


import Foundation
import SwiftUI

struct Stroke: Identifiable {
    let id = UUID()
    var points: [CGPoint]
    var color: Color
    var lineWidth: CGFloat

    init(points: [CGPoint] = [], color: Color = .black, lineWidth: CGFloat = 5) {
        self.points = points
        self.color = color
        self.lineWidth = lineWidth
    }
}
