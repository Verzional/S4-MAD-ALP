import SwiftUI
import PencilKit

class DrawingViewModel: ObservableObject {
    @Published var drawing = PKDrawing()
    @Published var strokeColor: Color = .black
    @Published var strokeWidth: CGFloat = 5
    @Published var tool: PKTool = PKInkingTool(.pen, color: .black, width: 5)
    @Published var pencilEnabled: Bool = false
    @Published var markerEnabled: Bool = false
    @Published var crayonEnabled: Bool = false
    
    
    func usePen() {
        tool = PKInkingTool(.pen, color: UIColor(strokeColor), width: strokeWidth)
    }

    func usePencil() {
        tool = PKInkingTool(.pencil, color: UIColor(strokeColor), width: strokeWidth)
    }

    func useMarker() {
        tool = PKInkingTool(.marker, color: UIColor(strokeColor), width: strokeWidth)
    }
    
    func useCrayon() {
        tool = PKInkingTool(.pencil, color: UIColor(strokeColor).withAlphaComponent(0.6), width: strokeWidth * 2.5)
    }

    func useSoftEraser() {
        tool = PKEraserTool(.bitmap)
    }

    func useStrokeEraser() {
        tool = PKEraserTool(.vector)
    }

    func updateToolColorOrWidth() {
        if let ink = (tool as? PKInkingTool)?.inkType {
            tool = PKInkingTool(ink, color: UIColor(strokeColor), width: strokeWidth)
        }
    }

    func clear() {
        drawing = PKDrawing()
    }
}
