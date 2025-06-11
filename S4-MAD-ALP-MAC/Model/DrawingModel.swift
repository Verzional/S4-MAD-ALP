import SwiftUI
import PencilKit

struct DrawingProject: Identifiable, Codable {
    let id: UUID
    
    var name: String?
    var drawing: PKDrawing
    let creationDate: Date
    var lastModifiedDate: Date
    var drawingDataFilename: String
    var userId: String?
    
    init(id: UUID, name: String?, drawing: PKDrawing, creationDate: Date, lastModifiedDate: Date, drawingDataFilename: String) {
        self.id = id
        self.name = name
        self.drawing = drawing
        self.creationDate = creationDate
        self.lastModifiedDate = lastModifiedDate
        self.drawingDataFilename = drawingDataFilename
    }
    
    init(name: String? = nil, drawing: PKDrawing, userId: String) {
        self.id = UUID()
        self.name = name
        self.drawing = drawing
        self.creationDate = Date()
        self.lastModifiedDate = Date()
        self.drawingDataFilename = "\(self.id.uuidString).pkdrawingdata"
        self.userId = userId
    }
    
    func generateThumbnail(size: CGSize = CGSize(width: 100, height: 100)) -> NSImage? {
            // If the drawing is empty, return a blank white image.
        guard !self.drawing.bounds.isEmpty else {
                return NSImage(size: size, flipped: false) { rect in
                    NSColor.white.setFill()
                    rect.fill()
                    return true
                }
            }

        let drawingRect = self.drawing.bounds

            // Calculate the aspect ratio to fit the drawing within the thumbnail size.
            let aspectWidth = size.width / drawingRect.width
            let aspectHeight = size.height / drawingRect.height
            let aspectRatio = min(aspectWidth, aspectHeight)

            let scaledDrawingSize = CGSize(
                width: drawingRect.width * aspectRatio,
                height: drawingRect.height * aspectRatio
            )
            
            // Center the scaled drawing within the thumbnail's bounds.
            let centeredRect = CGRect(
                x: (size.width - scaledDrawingSize.width) / 2.0,
                y: (size.height - scaledDrawingSize.height) / 2.0,
                width: scaledDrawingSize.width,
                height: scaledDrawingSize.height
            )

            // *** THE FIX IS HERE ***
            // First, render the PKDrawing data into an actual NSImage.
            // The scale of this intermediate image can be 1.0 since we are scaling it down anyway.
            // Using the main screen's scale is also a good option for quality.
            let scale = NSScreen.main?.backingScaleFactor ?? 1.0
        let imageFromDrawing = self.drawing.image(from: self.drawing.bounds, scale: scale)

            // Now, create the final thumbnail by drawing the generated image into the centered rect.
            return NSImage(size: size, flipped: true) { _ in
                imageFromDrawing.draw(in: centeredRect)
                return true
            }
        }
}

struct DrawingProjectMetadata: Identifiable, Codable {
    let id: UUID
    var name: String?
    let creationDate: Date
    var lastModifiedDate: Date
    var drawingDataFilename: String
}


