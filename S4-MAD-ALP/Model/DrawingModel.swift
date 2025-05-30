import SwiftUI
import PencilKit

struct DrawingModel {
    var drawing = PKDrawing()
    var tool: PKTool = PKInkingTool(.pen, color: .black, width: 5)
    var strokeColor: Color = .black
    var strokeWidth: CGFloat = 5
}
