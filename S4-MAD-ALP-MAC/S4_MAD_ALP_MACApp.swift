//
//  S4_MAD_ALP_MACApp.swift
//  S4-MAD-ALP-MAC
//
//  Created by Gabriela Sihutomo on 07/06/25.
//

import SwiftUI
import FirebaseCore

@main
struct S4_MAD_ALP_MACApp: App {
    @StateObject var userAuth = UserViewModel()
    @StateObject private var cmvm = ColorMixingViewModel()
    @StateObject var cvm = DrawingViewModel()
    
    init() {

            FirebaseApp.configure()
            
        }

    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userAuth)
                .environmentObject(cmvm)
                .environmentObject(cvm)
        }
    }
}
