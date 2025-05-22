//
//  ColorMixer.swift
//  S4-MAD-ALP
//
//  Created by student on 22/05/25.
//

import Foundation
import SwiftUI

func mixColors(hex1: String, hex2: String) -> String {
    func hexToRGB(_ hex: String) -> (CGFloat, CGFloat, CGFloat) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexSanitized.hasPrefix("#") { hexSanitized.removeFirst() }

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0

        return (r, g, b)
    }

    func rgbToHex(r: CGFloat, g: CGFloat, b: CGFloat) -> String {
        let red = Int(round(r * 255))
        let green = Int(round(g * 255))
        let blue = Int(round(b * 255))
        return String(format: "#%02X%02X%02X", red, green, blue)
    }

    let (r1, g1, b1) = hexToRGB(hex1)
    let (r2, g2, b2) = hexToRGB(hex2)

    let mixedR = (r1 + r2) / 2
    let mixedG = (g1 + g2) / 2
    let mixedB = (b1 + b2) / 2

    return rgbToHex(r: mixedR, g: mixedG, b: mixedB)
}
