//
//  S4_MAD_ALP_MACApp.swift
//  S4-MAD-ALP-MAC
//
//  Created by Gabriela Sihutomo on 07/06/25.
//

import SwiftUI
import FirebaseAppCheck
import FirebaseCore

@main
struct S4_MAD_ALP_MACApp: App {
    @StateObject var userAuth = UserViewModel()
    @StateObject private var cmvm = ColorMixingViewModel()
    
    init() {
        FirebaseApp.configure()
        #if DEBUG
            let providerFactory = AppCheckDebugProviderFactory()
            AppCheck.setAppCheckProviderFactory(providerFactory)
        #endif
    }

    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userAuth)
                .environmentObject(cmvm)
        }
    }
}
