//
//  ProjectsView.swift
//  S4-MAD-ALP
//
//  Created by student on 03/06/25.
//

import SwiftUI
import PencilKit

struct ProjectsView: View {
    @EnvironmentObject var userData: UserViewModel
    @EnvironmentObject var cvm: DrawingViewModel
    @EnvironmentObject var cvcm: ColorMixingViewModel

    let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 20)
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Text("Your Projects")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                    NavigationLink(destination: DrawingView(existingProject: nil)
                                    .environmentObject(cvm)
                                    .environmentObject(userData)
                                    .environmentObject(cvcm)
                    ) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundColor(.accentColor)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                .padding(.bottom, 10)

                if userData.projects.isEmpty {
                    Spacer()
                    VStack {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.7))
                        Text("No Projects Yet")
                            .font(.headline)
                            .padding(.top, 8)
                        Text("Tap the '+' button to create your first drawing!")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(userData.projects) { project in
                                NavigationLink(destination: DrawingView(existingProject: project)
                                    .environmentObject(cvm)
                                    .environmentObject(userData)
                                    .environmentObject(cvcm)
                                ) {
                                    ProjectCardView(project: project)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                userData.loadProjectsFromDisk()
            }
        }

    }
}

#Preview {
    ProjectsView()
        .environmentObject(UserViewModel())
        .environmentObject(DrawingViewModel())
        .environmentObject(ColorMixingViewModel())
}
