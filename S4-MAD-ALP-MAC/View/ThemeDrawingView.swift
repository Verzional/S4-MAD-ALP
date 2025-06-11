//
//  ThemeDrawingView.swift
//  S4-MAD-ALP
//
//  Created by Gabriela Sihutomo on 11/06/25.
//

import SwiftUI

struct ThemeDrawingView: View {
    @EnvironmentObject var cvm: DrawingViewModel
    @EnvironmentObject var uvm: UserViewModel
    @EnvironmentObject var cmvm: ColorMixingViewModel
    @StateObject var tvm = ThemeDrawingViewModel()
    
    var body: some View {
        Text(tvm.generatedPrompt)
            .font(.title3)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
        DrawingView()
            .environmentObject(cvm)
            .environmentObject(uvm)
            .environmentObject(cmvm)
    }
}

#Preview {
    ThemeDrawingView()
        .environmentObject(DrawingViewModel())
        .environmentObject(UserViewModel())
        .environmentObject(ColorMixingViewModel())
        .environmentObject(ThemeDrawingViewModel())
}
