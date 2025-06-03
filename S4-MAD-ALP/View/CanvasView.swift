//
//  CanvasView.swift
//  S4-MAD-ALP
//
//  Created by student on 22/05/25.
//

import SwiftUI
import Firebase

struct CanvasView: View {
    @EnvironmentObject var cvm: DrawingViewModel
    @EnvironmentObject var cmvm: ColorMixingViewModel
    @EnvironmentObject var userData: UserViewModel
    @EnvironmentObject var canvas: CanvasViewModel
    
    @State private var showingSaveAlert = false
        @State private var saveAlertTitle = ""
        @State private var saveAlertMessage = ""
    
    var body: some View {
        DrawingView()
            .environmentObject(cvm)
            .environmentObject(cmvm)
            .environmentObject(userData)
    }
}

#Preview {
    CanvasView()
        .environmentObject(CanvasViewModel())
        .environmentObject(ColorMixingViewModel())
        .environmentObject(DrawingViewModel())
        .environmentObject(UserViewModel())
}
