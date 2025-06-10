//
//  ProjectCardView.swift
//  S4-MAD-ALP
//
//  Created by student on 03/06/25.
//

import SwiftUI

struct ProjectCardView: View {
    let project: DrawingProject

      var body: some View {
          VStack(alignment: .leading) {
              if let thumbnail = project.generateThumbnail(size: CGSize(width: 150, height: 120)) {
                  Image(nsImage: thumbnail)
                      .resizable()
                      .aspectRatio(contentMode: .fill) // Or .fit depending on desired look
                      .frame(minWidth: 0, maxWidth: .infinity) // Make image take available width
                      .frame(height: 120) // Fixed height for consistency
                      .background(Color.gray.opacity(0.1)) // Placeholder background
                      .clipped() // Clip image to its frame
              } else {
                  // Placeholder if thumbnail generation fails or drawing is empty
                  Rectangle()
                      .fill(Color.gray.opacity(0.2))
                      .frame(minWidth: 0, maxWidth: .infinity)
                      .frame(height: 120)
                      .overlay(
                          Image(systemName: "photo.fill")
                              .foregroundColor(.gray)
                              .font(.largeTitle)
                      )
              }

              VStack(alignment: .leading, spacing: 4) {
                  Text(project.name ?? "Untitled Drawing")
                      .font(.headline)
                      .lineLimit(1)
                  Text("Created: \(project.creationDate, style: .date)")
                      .font(.caption)
                      .foregroundColor(.secondary)
              }
              .padding([.horizontal, .bottom], 8)
              .padding(.top, 4)
          }
          .background(Color(.gray)) // Card background
          .cornerRadius(12)
          .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
      }
}
