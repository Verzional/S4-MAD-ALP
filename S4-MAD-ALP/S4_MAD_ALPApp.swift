//
//  S4_MAD_ALPApp.swift
//  S4-MAD-ALP
//
//  Created by student on 22/05/25.
//

import SwiftUI

@main
struct S4_MAD_ALPApp: App {
    @StateObject private var cvm = DrawingViewModel()
    @StateObject private var cmvm = ColorMixingViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(cvm)
                .environmentObject(cmvm)
        }
    }
}
