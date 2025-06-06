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
    @Published var selectedTab: ToolTab = .tools
    
    enum ToolTab: String, CaseIterable, Identifiable {
        case tools = "Tools"
        case colors = "Colors"
        case size = "Size"

        var id: String { self.rawValue }
        var systemImage: String {
            switch self {
            case .tools: return "pencil.and.outline"
            case .colors: return "paintpalette.fill"
            case .size: return "paintbrush.pointed.fill"
            }
        }
    }
    
    
    
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
}
