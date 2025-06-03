import SwiftUI
import PencilKit
import Photos
import UIKit

class DrawingViewModel: ObservableObject {
    @Published var drawing = PKDrawing()
    @Published var strokeColor: Color = .black
    @Published var strokeWidth: CGFloat = 10
    @Published var tool: PKTool = PKInkingTool(.pen, color: .black, width: 5)
    @Published var pencilEnabled: Bool = false
    @Published var markerEnabled: Bool = false
    @Published var crayonEnabled: Bool = false
    enum DrawingToolType {
        case pen, pencil, marker, crayon, softEraser, strokeEraser
    }

    @Published var currentTool: DrawingToolType = .pen
    
    
    func usePen() {
        tool = PKInkingTool(.pen, color: UIColor(strokeColor), width: strokeWidth)
        currentTool = .pen
    }

    func usePencil() {
        tool = PKInkingTool(.pencil, color: UIColor(strokeColor), width: strokeWidth)
        currentTool = .pencil
    }

    func useMarker() {
        tool = PKInkingTool(.marker, color: UIColor(strokeColor), width: strokeWidth)
        currentTool = .marker
    }
    
    func useCrayon() {
        tool = PKInkingTool(.pencil, color: UIColor(strokeColor).withAlphaComponent(0.6), width: strokeWidth * 2.5)
        currentTool = .crayon
    }

    func useSoftEraser() {
        tool = PKEraserTool(.bitmap, width: strokeWidth*5)
        currentTool = .softEraser
    }

    func useStrokeEraser() {
        tool = PKEraserTool(.vector)
        currentTool = .strokeEraser
    }

    func updateToolColorOrWidth() {
        if let ink = (tool as? PKInkingTool)?.inkType {
            tool = PKInkingTool(ink, color: UIColor(strokeColor), width: strokeWidth)
        }
        if let eraser = tool as? PKEraserTool {
            tool = PKEraserTool(.bitmap, width: strokeWidth*5)
        }
    }

    func clear() {
        drawing = PKDrawing()
    }
    
    func levelCheck(level: Int) {
        if(level>=2){
            pencilEnabled = true
        }
        if(level>=4){
            markerEnabled = true
        }
        if(level>=6){
            crayonEnabled = true
        }
    }
    
    func saveDrawing(completion: @escaping (Bool, String?) -> Void) {
            Task {
                let (success, message) = await saveDrawingToPhotoLibraryModern(background: .white)
                DispatchQueue.main.async {
                    completion(success, message)
                }
            }
        }
    
    private func renderPKDrawingToUIImage(pkDrawing: PKDrawing, size: CGSize, background: UIColor) -> UIImage {
        // Create an off-screen PKCanvasView instance
        let tempCanvasView = PKCanvasView(frame: CGRect(origin: .zero, size: size))
        tempCanvasView.drawing = pkDrawing
        tempCanvasView.backgroundColor = background // Set background for the rendered image

        // Render the drawing from the PKCanvasView to a UIImage
        // This implicitly uses drawing.image(from:tempCanvasView.bounds, scale:) or similar.
        let image = tempCanvasView.drawing.image(from: tempCanvasView.bounds, scale: UIScreen.main.scale)
        return image
    }
    
    func saveDrawingToPhotoLibraryModern(background: UIColor = .white) async -> (Bool, String?) {
            let imageSize: CGSize
            if drawing.bounds.isEmpty {
                // If drawing is empty, use a default size for the saved image.
                imageSize = CGSize(width: 500, height: 500) // Default size for an empty canvas save
            } else {
                // Get the bounding box of the strokes to make the image size fit the drawing
                imageSize = drawing.bounds.size
            }

            let renderer = UIGraphicsImageRenderer(size: imageSize)

        let image = renderPKDrawingToUIImage(pkDrawing: drawing, size: imageSize, background: background)

            let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
            if status == .notDetermined {
                let newStatus = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
                if newStatus != .authorized {
                    return (false, "Photo Library access denied. Please enable access in Settings.")
                }
            } else if status == .denied || status == .restricted {
                return (false, "Photo Library access denied. Please enable access in Settings.")
            }

            do {
                try await PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }
                return (true, nil)
            } catch {
                print("Error saving to photo library: \(error.localizedDescription)")
                return (false, "Failed to save drawing: \(error.localizedDescription)")
            }
        }

    
    
}
