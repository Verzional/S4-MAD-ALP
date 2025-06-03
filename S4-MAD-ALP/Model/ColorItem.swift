//
//  ColorItem.swift
//  S4-MAD-ALP
//
//  Created by student on 22/05/25.
//

import Foundation

struct ColorItem: Identifiable, Equatable, Codable, Hashable {
    let id: UUID
    let name: String
    let hex: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
