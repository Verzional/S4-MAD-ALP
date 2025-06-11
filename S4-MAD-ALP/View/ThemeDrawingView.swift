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
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .font(.title3)
            .fontWeight(.bold)
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
}
