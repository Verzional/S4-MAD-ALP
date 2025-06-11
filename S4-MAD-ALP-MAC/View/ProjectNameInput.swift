//
//  ProjectNameInput.swift
//  S4-MAD-ALP
//
//  Created by student on 03/06/25.
//

import SwiftUI
import PencilKit

struct ProjectNameInput: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var uvm: UserViewModel
        var drawingToSave: PKDrawing
        @State  var projectName: String = ""
    
    var body: some View {

                VStack {
                    VStack(spacing: 20) {
                        Text("Name Your Project")
                            .font(.headline)

                        TextField("Enter project name (optional)", text: $projectName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        

                        HStack(spacing: 20) {
                            Button("Cancel") { dismiss() }
                            Button("Save") {
                                uvm.addProject(name: projectName.isEmpty ? nil : projectName, drawing: drawingToSave)
                                dismiss()
                                dismiss()
                            }
                            .disabled(projectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && false)
                        }
                        Spacer()
                    }
                    .padding()
                    .navigationTitle("New Project")
                    
                }
            
    }
}

