//
//  MainView.swift
//  S4-MAD-ALP
//
//  Created by student on 22/05/25.
//

import SwiftUI

struct MainView: View {
    
    var body: some View {
        TabView {
            MinigamesView().tabItem{
                Label("Minigames", systemImage: "gamecontroller.fill")
            }
            
            ProjectsView().tabItem {
                Label("Drawing", systemImage:"photo.fill")
            }
            
            ColorMixingView().tabItem {
                Label("Mixing", systemImage: "paintpalette.fill")
            }
            
            ProfileView().tabItem{
                Label("Profile", systemImage: "person.fill")
            }
        }
        
    }
}

#Preview {
    do{
        var uvm = UserViewModel()
        uvm.userModel.level = 10
        return MainView()
            .environmentObject(uvm)
            .environmentObject(DrawingViewModel())
            .environmentObject(ColorMixingViewModel())
    }
    
}
