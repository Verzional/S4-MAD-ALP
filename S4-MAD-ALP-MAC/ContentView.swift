//
//  ContentView.swift
//  S4-MAD-ALP-MAC
//
//  Created by Gabriela Sihutomo on 07/06/25.
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
}
