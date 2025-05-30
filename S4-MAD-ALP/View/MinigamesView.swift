//
//  MinigamesView.swift
//  S4-MAD-ALP
//
//  Created by student on 30/05/25.
//

import SwiftUI

struct MinigamesView: View {
    var body: some View {
        NavigationStack{
            let columns = [
                GridItem(.flexible()),
                GridItem(.flexible())
            ]

            LazyVGrid(columns: columns, spacing: 20) {
                NavigationLink(destination: MemorizingGameView()) {
                    VStack {
                        Image(systemName: "gamecontroller.fill")
                            .font(.title2)
                        Text("Memorize game")
                            .font(.headline)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 30)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(15)
                    .foregroundColor(.black)
                }
                .padding(.top, 20)
                NavigationLink(destination: MemorizingGameView()) {
                    VStack {
                        Image(systemName: "gamecontroller.fill")
                            .font(.title2)
                        Text("Memorize game")
                            .font(.headline)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 30)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(15)
                    .foregroundColor(.black)
                }
                .padding(.top, 20)
                NavigationLink(destination: MemorizingGameView()) {
                    VStack {
                        Image(systemName: "gamecontroller.fill")
                            .font(.title2)
                        Text("Memorize game")
                            .font(.headline)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 30)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(15)
                    .foregroundColor(.black)
                }
                .padding(.top, 20)
            }
    
                
            }
        
    }
}

#Preview {
    MinigamesView()
}
