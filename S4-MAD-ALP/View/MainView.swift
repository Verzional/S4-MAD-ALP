//
//  MainView.swift
//  S4-MAD-ALP
//
//  Created by student on 22/05/25.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var cvm: CanvasViewModel
    @EnvironmentObject var cmvm: ColorMixingViewModel
    
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
