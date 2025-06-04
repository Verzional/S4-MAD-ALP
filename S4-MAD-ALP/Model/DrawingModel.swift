import SwiftUI
import PencilKit

struct DrawingProject: Identifiable, Codable {
    let id: UUID
    var name: String?
    var drawing: PKDrawing // This will be loaded from a file
    let creationDate: Date
    var lastModifiedDate: Date
    var drawingDataFilename: String // Name of the file storing the PKDrawing data

    init(id: UUID, name: String?, drawing: PKDrawing, creationDate: Date, lastModifiedDate: Date, drawingDataFilename: String) {
        self.id = id
        self.name = name
        self.drawing = drawing
        self.creationDate = creationDate
        self.lastModifiedDate = lastModifiedDate
        self.drawingDataFilename = drawingDataFilename
    }

    init(name: String? = nil, drawing: PKDrawing) {
        self.id = UUID()
        self.name = name
        self.drawing = drawing
        self.creationDate = Date()
        self.lastModifiedDate = Date()
        self.drawingDataFilename = "\(self.id.uuidString).pkdrawingdata"
    }
    
    func generateThumbnail(size: CGSize = CGSize(width: 100, height: 100), scale: CGFloat = 1.0) -> UIImage? {
            guard !drawing.bounds.isEmpty else {
                UIGraphicsBeginImageContextWithOptions(size, false, scale)
                defer { UIGraphicsEndImageContext() }
                UIColor.systemGray5.setFill()
                UIRectFill(CGRect(origin: .zero, size: size))
                return UIGraphicsGetImageFromCurrentImageContext()
            }

            let drawingRect = drawing.bounds
            let imageRect = CGRect(origin: .zero, size: size)
            

            let aspectWidth = size.width / drawingRect.width
            let aspectHeight = size.height / drawingRect.height
            let aspectRatio = min(aspectWidth, aspectHeight) // Use min to fit, max to fill (then clip)

            let scaledDrawingSize = CGSize(width: drawingRect.width * aspectRatio, height: drawingRect.height * aspectRatio)
            let centeredRect = CGRect(
                x: (size.width - scaledDrawingSize.width) / 2.0,
                y: (size.height - scaledDrawingSize.height) / 2.0,
                width: scaledDrawingSize.width,
                height: scaledDrawingSize.height
            )

            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            defer { UIGraphicsEndImageContext() }
            

            let imageFromDrawing = drawing.image(from: drawing.bounds, scale: scale) // Get image at native scale
            imageFromDrawing.draw(in: centeredRect) // Draw it scaled and centered into the thumbnail context

            return UIGraphicsGetImageFromCurrentImageContext()
        }
    
}

struct DrawingProjectMetadata: Identifiable, Codable {
    let id: UUID
    var name: String?
    let creationDate: Date
    var lastModifiedDate: Date
    var drawingDataFilename: String
}


