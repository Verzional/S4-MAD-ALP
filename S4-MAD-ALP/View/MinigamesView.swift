//
//  MinigamesView.swift
//  S4-MAD-ALP
//
//  Created by student on 30/05/25.
//

import SwiftUI

struct MinigamesView: View {
    @EnvironmentObject var uvm: UserViewModel
    
    // Grid layout with more spacing for a cleaner look
    private let columns = [
        GridItem(.flexible(), spacing: 25),
        GridItem(.flexible(), spacing: 25)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        // --- Playful Header ---
                        HStack {
                            Text("Minigames")
                                .font(.system(size: 44, weight: .heavy, design: .rounded))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                            
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal)
                        
                        // --- Grid of Games ---
                        LazyVGrid(columns: columns, spacing: 25) {
                            createGameLink(
                                destination: TraceImageGameView(),
                                icon: "scribble.variable",
                                title: "Tracing Fun",
                                color: .orange,
                                isLocked: false
                            )
                            
                            createGameLink(
                                destination: ConnectTheDotsGameView(),
                                icon: "point.3.connected.trianglepath.dotted",
                                title: "Connect Dots",
                                color: .green,
                                isLocked: false
                            )
                            
                            createGameLink(
                                destination: ThemeDrawingView(),
                                icon: "paintpalette.fill",
                                title: "Art Class",
                                color: .purple,
                                isLocked: uvm.userModel.level < 8,
                                unlockLevel: 8
                            )
                            
                            createGameLink(
                                destination: MemoryGameView(),
                                icon: "brain.head.profile.fill",
                                title: "Memory Draw",
                                color: .red,
                                isLocked: uvm.userModel.level < 10,
                                unlockLevel: 10
                            )
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
            }
            
            .navigationTitle("")
        
        }
    }
    
    /// Helper function to reduce repetitive code for creating game links
    @ViewBuilder
    private func createGameLink<Destination: View>(destination: Destination, icon: String, title: String, color: Color, isLocked: Bool, unlockLevel: Int? = nil) -> some View {
        NavigationLink(destination: destination) {
            GameCardView(iconName: icon, title: title, cardColor: color, isLocked: isLocked, unlockLevel: unlockLevel)
        }
        .buttonStyle(SquishableButtonStyle()) // Apply the fun, bouncy animation
        .disabled(isLocked)
    }
}

struct GameCardView: View {
    let iconName: String
    let title: String
    let cardColor: Color // Each card can have a unique color
    var isLocked: Bool = false
    var unlockLevel: Int? = nil
    
    var body: some View {
        ZStack {
            // Main card content
            VStack(spacing: 15) {
                Image(systemName: iconName)
                    .font(.system(size: 50)) // Bigger icon
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.system(.headline, design: .rounded)) // Rounded font
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .padding(20)
            .frame(maxWidth: .infinity, minHeight: 160)
            .background(cardColor) // Use the vibrant card color
            .cornerRadius(25) // Softer, rounder corners
            .shadow(color: cardColor.opacity(0.5), radius: 8, x: 0, y: 6) // Playful shadow
            
            // --- Locked State Overlay ---
            if isLocked {
                // Dimming overlay with the same rounded corners
                Color.black.opacity(0.6)
                    .cornerRadius(25)
                
                VStack {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 40, design: .rounded))
                    Text("Locked")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
                        .padding(.top, 4)
                    if let level = unlockLevel {
                        Text("Get to Level \(level)!")
                            .font(.system(.callout, design: .rounded))
                            .fontWeight(.medium)
                    }
                }
                .foregroundColor(.white)
            }
        }
    }
}

struct SquishableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0) // Shrinks the view when pressed
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

#Preview {
    let previewUvm = UserViewModel()
    // Try setting different levels to see the locked/unlocked state
    // e.g., 7, 8, 10
    previewUvm.userModel.level = 7
    
    return MinigamesView()
        .environmentObject(previewUvm)
}
