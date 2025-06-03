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
    @StateObject private var cvm = DrawingViewModel()
    @StateObject private var cmvm = ColorMixingViewModel()
    @StateObject var userAuth = UserViewModel()
    @StateObject private var themeDrawing = ThemeDrawingViewModel()

    init() {
        FirebaseApp.configure()
        #if DEBUG
            let providerFactory = AppCheckDebugProviderFactory()
            AppCheck.setAppCheckProviderFactory(providerFactory)
        #endif
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(cvm)
                .environmentObject(cmvm)
                .environmentObject(themeDrawing)
        }
        .environmentObject(userAuth)
    }
}
