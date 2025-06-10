//
//  ContentView.swift
//  S4-MAD-ALP-MAC
//
//  Created by Gabriela Sihutomo on 07/06/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        DrawingView()
            .environmentObject(DrawingViewModel())
    }
}

#Preview {
    ContentView()
        .environmentObject(DrawingViewModel())
}
