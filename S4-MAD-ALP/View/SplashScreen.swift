//
//  SplashScreen.swift
//  S4-MAD-ALP
//
//  Created by Gabriela Sihutomo on 12/06/25.
//

import SwiftUI

struct SplashScreen: View {
    var body: some View {
        VStack{
            Image("HueCraft")
                .resizable()
                .frame(maxWidth: 150, maxHeight: 150)
        }.frame(minWidth: 1000, minHeight: 600, maxHeight: .infinity)
            .background(
            LinearGradient(
            stops: [
            Gradient.Stop(color: Color(red: 0.98, green: 0.7, blue: 0.32), location: 0.00),
            Gradient.Stop(color: Color(red: 1, green: 0.32, blue: 0.31), location: 0.31),
            Gradient.Stop(color: Color(red: 0.71, green: 0.34, blue: 0.82), location: 0.77),
            Gradient.Stop(color: Color(red: 0.13, green: 0.49, blue: 0.91), location: 1.00),
            ],
            startPoint: UnitPoint(x: 0.91, y: 0),
            endPoint: UnitPoint(x: 0.09, y: 1)
            )
        )
        
    }
}

#Preview {
    SplashScreen()
}
