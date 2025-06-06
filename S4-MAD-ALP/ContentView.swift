//
//  ContentView.swift
//  S4-MAD-ALP
//
//  Created by student on 22/05/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userAuth: UserViewModel
    
    var body: some View {
        if userAuth.isLogin {
            MainView()
        } else {
            UserView() 
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(UserViewModel())
        .environmentObject(DrawingViewModel())
        .environmentObject(ColorMixingViewModel())
        .environmentObject(ThemeDrawingViewModel())
}
