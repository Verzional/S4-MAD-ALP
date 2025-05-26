//
//  S4_MAD_ALPApp.swift
//  S4-MAD-ALP
//
//  Created by student on 22/05/25.
//

import FirebaseAppCheck
import FirebaseCore
import SwiftUI

@main
struct S4_MAD_ALPApp: App {
    @StateObject var userAuth = UserViewModel() // Create a single instance here

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
        }
        .environmentObject(userAuth)
    }
}
