import SwiftUI
import PencilKit
import AppKit // Use AppKit for macOS UI components

struct DrawingView: View {
    @EnvironmentObject var cvm: DrawingViewModel
    @EnvironmentObject var cmvm: ColorMixingViewModel
    @EnvironmentObject var uvm: UserViewModel // Depend on the protocol
    
    @State private var showingColorPickerSheet = false
    
    @Environment(\.dismiss) var dismiss
    
    var existingProject: DrawingProject?
    
    @State var presentNameInputView: Bool = false
    
    var body: some View {
        VStack(spacing: 15) {
            // Use the new custom editable canvas for macOS
            EditableCanvasView(drawing: cvm.drawing, tool: $cvm.tool)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 3)
                .layoutPriority(1)
                .environmentObject(cvm)

            toolPickerSection
                .padding(.horizontal)

            HStack(spacing: 15) {
                HStack(spacing: 5) {
                    if let project = existingProject {
                        Button(action: {
                            uvm.deleteProject(project)
                            dismiss() // Dismiss the view after deleting
                        }) {
                            Circle()
                                .fill(.red)
                                .frame(width: 44, height: 44)
                                .overlay(Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1))
                                .overlay(
                                    Image(systemName: "trash")
                                        .foregroundColor(.white)
                                        .font(.system(size: 20))
                                )
                                .shadow(radius: 2)
                        }
                    }
                    Button(action: {
                        if let project = existingProject {
                            uvm.updateProjectDrawing(projectID: project.id, newDrawing: cvm.drawing)
                            dismiss()
                        } else {
                            presentNameInputView = true
                        }
                    }) {
                        Circle()
                            .fill(.blue)
                            .frame(width: 44, height: 44)
                            .overlay(Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1))
                            .overlay(
                                Image(systemName: "square.and.arrow.down")
                                    .foregroundColor(.white)
                                    .font(.system(size: 20))
                            )
                            .shadow(radius: 2)
                    }
                }
                
                brushSizeSection
                
                Button(action: {
                    showingColorPickerSheet = true
                }) {
                    Circle()
                        .fill(cvm.strokeColor)
                        .frame(width: 44, height: 44)
                        .overlay(Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1))
                        .overlay(
                            Image(systemName: "paintpalette.fill")
                                .foregroundColor(cvm.strokeColor.isDark ? .white : .black)
                                .font(.system(size: 20))
                        )
                        .shadow(radius: 2)
                }
            }
            .padding(.horizontal)
            .frame(height: 60)
        }
        .padding()
        .background(Color(.windowBackgroundColor).ignoresSafeArea()) // Use macOS system color
        .sheet(isPresented: $showingColorPickerSheet) {
            ColorPickerSheetView(onColorSelect: { selectedColorItem in
                cvm.strokeColor = Color(hex: selectedColorItem.hex)
                cvm.updateToolColorOrWidth()
                showingColorPickerSheet = false
            })
            .environmentObject(cmvm)
        }
        .onAppear {
            cvm.levelCheck(level: uvm.userModel.level)
            if let project = existingProject {
                cvm.drawing = project.drawing
            }
        }
        .sheet(isPresented: $presentNameInputView) {
            
        }
    }
    
    private func toolButton(icon: String, toolType: DrawingViewModel.DrawingToolType, action: @escaping () -> Void) -> some View {
        let isSelected = cvm.currentTool == toolType
        let isDisabled: Bool
        switch toolType {
        case .pencil: isDisabled = !cvm.pencilEnabled
        case .marker: isDisabled = !cvm.markerEnabled
        case .crayon: isDisabled = !cvm.crayonEnabled
        default: isDisabled = false
        }
        
        return Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isDisabled ? .gray : (isSelected ? Color.white : Color.accentColor))
                .frame(width: 44, height: 44)
                .background(isSelected ? Color.accentColor : Color(.controlColor)) // macOS color
                .clipShape(Circle())
                .shadow(radius: isSelected ? 3 : 1)
        }
        .disabled(isDisabled)
    }
    
    private var toolPickerSection: some View {
        HStack(spacing: 12) {
            toolButton(icon: "pencil.tip", toolType: .pen, action: cvm.usePen)
            toolButton(icon: "pencil", toolType: .pencil, action: cvm.usePencil)
            toolButton(icon: "paintbrush.pointed", toolType: .marker, action: cvm.useMarker)
            toolButton(icon: "highlighter", toolType: .crayon, action: cvm.useCrayon)
            Spacer()
            toolButton(icon: "eraser", toolType: .softEraser, action: cvm.useSoftEraser)
            toolButton(icon: "scissors", toolType: .strokeEraser, action: cvm.useStrokeEraser)
        }
        .padding(.vertical, 5)
    }
    
    private var brushSizeSection: some View {
        HStack(spacing: 10) {
            Image(systemName: "circle.fill")
                .font(.system(size: 8))
                .foregroundColor(.gray)
            
            Slider(value: $cvm.strokeWidth, in: 1...30, step: 1) {
                Text("Brush Size")
            }
            .tint(cvm.strokeColor)
            .onChange(of: cvm.strokeWidth) {
                cvm.updateToolColorOrWidth()
            }
            
            Image(systemName: "circle.fill")
                .font(.system(size: 20))
                .foregroundColor(.gray)
            
            Text("\(Int(cvm.strokeWidth))pt")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 40, alignment: .trailing)
        }
    }
}

// MARK: - Custom Editable Canvas for macOS

struct EditableCanvasView: NSViewRepresentable {
    var drawing: PKDrawing
    @Binding var tool: PKTool
    
    @EnvironmentObject var cvm: DrawingViewModel

    func makeNSView(context: Context) -> CustomCanvasView {
        let view = CustomCanvasView()
        view.drawing = drawing
        view.tool = tool
        
        // Add explicit type annotation here to be safe
        view.strokeDidFinish = { (stroke: PKStroke) in
            cvm.addStroke(stroke)
        }
        
        // THE FIX: Add the explicit type `PKStroke` to the parameter
        view.strokeDidRequestRemoval = { (stroke: PKStroke) in
            cvm.removeStroke(stroke)
        }
        
        return view
    }

    func updateNSView(_ nsView: CustomCanvasView, context: Context) {
        nsView.tool = tool
        
        // THE FIX: The canvas's local drawing can now be different from the
        // ViewModel's. This ensures that when a stroke is deleted from the
        // ViewModel, the canvas updates to show that deletion.
        if nsView.drawing.strokes.count != drawing.strokes.count {
             nsView.drawing = drawing
        }
    }
}

class CustomCanvasView: NSView {
    var drawing = PKDrawing() {
        didSet {
            needsDisplay = true // Redraw when data changes
        }
    }
    
    var tool: PKTool = PKInkingTool(.pen, color: .black)
    var strokeDidFinish: (PKStroke) -> Void = { _ in }
    var strokeDidRequestRemoval: (PKStroke) -> Void = { _ in }
    
    private var currentPoints: [PKStrokePoint] = []
    
    override var acceptsFirstResponder: Bool { true }

    // MARK: - The Corrected Drawing Method
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard let context = NSGraphicsContext.current?.cgContext else { return }

        // 1. Fill the background
        context.setFillColor(NSColor.white.cgColor)
        context.fill(bounds)

        // 2. Manually render all committed strokes
        for stroke in self.drawing.strokes {
            context.setStrokeColor(stroke.ink.color.cgColor)
            context.setLineCap(.round)
            context.setLineJoin(.round)
            
            // --- THIS IS THE FIX ---
            // Get the width from the 'size' of the first point in the stroke's path.
            if let firstPoint = stroke.path.first {
                context.setLineWidth(firstPoint.size.width)
            }
            // -----------------------
            
            let cgPath = CGMutablePath()
            let points = stroke.path.map { $0.location }
            
            if let firstPoint = points.first {
                cgPath.move(to: firstPoint)
                cgPath.addLines(between: points)
                context.addPath(cgPath)
                context.strokePath()
            }
        }
        
        // 3. Draw the live, in-progress stroke on top
        drawLiveStroke(in: context)
    }

    private func drawLiveStroke(in context: CGContext) {
        guard !currentPoints.isEmpty else { return }

        // This part is correct because PKInkingTool *does* have a .width
        if let inkTool = tool as? PKInkingTool {
            context.setStrokeColor(inkTool.color.cgColor)
            context.setLineWidth(inkTool.width)
        } else if let eraser = tool as? PKEraserTool, eraser.eraserType == .bitmap {
            context.setStrokeColor(NSColor.white.cgColor)
            context.setLineWidth(eraser.width)
        }
        
        context.setLineCap(.round)
        context.setLineJoin(.round)
        
        let livePath = CGMutablePath()
        if let firstPoint = currentPoints.first {
            livePath.move(to: firstPoint.location)
            livePath.addLines(between: currentPoints.map { $0.location })
            context.addPath(livePath)
            context.strokePath()
        }
    }

    // MARK: - State Management (Unchanged from previous correct version)
    override func mouseUp(with event: NSEvent) {
        if !currentPoints.isEmpty {
            let path = PKStrokePath(controlPoints: currentPoints, creationDate: Date())
            var finalStroke: PKStroke? = nil
            
            if let inkTool = tool as? PKInkingTool {
                finalStroke = PKStroke(ink: inkTool.ink, path: path)
            } else if let eraserTool = tool as? PKEraserTool, eraserTool.eraserType == .bitmap {
                let whiteInk = PKInk(.pen, color: .white)
                // Use the eraserTool's width to define the size of the points for the new stroke
                let eraserPoints = path.map { PKStrokePoint(location: $0.location, timeOffset: $0.timeOffset, size: CGSize(width: eraserTool.width, height: eraserTool.width), opacity: $0.opacity, force: $0.force, azimuth: $0.azimuth, altitude: $0.altitude) }
                let eraserPath = PKStrokePath(controlPoints: eraserPoints, creationDate: Date())
                finalStroke = PKStroke(ink: whiteInk, path: eraserPath)
            }
            
            if let stroke = finalStroke {
                self.drawing = PKDrawing(strokes: self.drawing.strokes + [stroke])
                strokeDidFinish(stroke)
            }
        }
        currentPoints = []
    }
    
    // Unchanged mouse and helper methods
    override func mouseDown(with event: NSEvent) {
        let location = convert(event.locationInWindow, from: nil)

        // NEW ERASER LOGIC:
        if let eraser = tool as? PKEraserTool, eraser.eraserType == .vector {
            if let strokeToRemove = findStroke(at: location) {
                // Use the new callback to request deletion
                strokeDidRequestRemoval(strokeToRemove)
            }
            return // Stop here for the vector eraser
        }

        // This is the existing logic for drawing tools
        currentPoints = []
        currentPoints.append(createStrokePoint(at: location, event: event))
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        let location = convert(event.locationInWindow, from: nil)

        // NEW ERASER LOGIC:
        if let eraser = tool as? PKEraserTool, eraser.eraserType == .vector {
            if let strokeToRemove = findStroke(at: location) {
                strokeDidRequestRemoval(strokeToRemove)
            }
            return // Stop here for the vector eraser
        }

        // Existing logic for drawing tools
        currentPoints.append(createStrokePoint(at: location, event: event))
        needsDisplay = true
    }

    // This helper function is needed to find the stroke under the cursor
    private func findStroke(at location: NSPoint) -> PKStroke? {
        var closestStroke: PKStroke? = nil
        var minDistance: CGFloat = .greatestFiniteMagnitude

        // Iterate through strokes in reverse to find the one on top
        for stroke in drawing.strokes.reversed() {
            // Find the minimum distance from the erase point to any point in the stroke
            let currentMinDistance = stroke.path.map { point -> CGFloat in
                let dx = point.location.x - location.x
                let dy = point.location.y - location.y
                return sqrt(dx*dx + dy*dy)
            }.min() ?? .greatestFiniteMagnitude

            // If the stroke is close enough to the cursor, select it
            // You can adjust the "15.0" threshold for sensitivity
            if currentMinDistance < 15.0 && currentMinDistance < minDistance {
                minDistance = currentMinDistance
                closestStroke = stroke
            }
        }
        return closestStroke
    }
    
    private func createStrokePoint(at location: NSPoint, event: NSEvent) -> PKStrokePoint {
        var pointSize: CGSize = .zero
        if let inkTool = tool as? PKInkingTool { pointSize = CGSize(width: inkTool.width, height: inkTool.width) }
        else if let eraserTool = tool as? PKEraserTool { pointSize = CGSize(width: eraserTool.width, height: eraserTool.width) }
        // For simplicity, we use the tool's width for all points. A more advanced implementation
        // would vary the size based on pressure, which is available in event.pressure.
        return PKStrokePoint(location: location, timeOffset: 0, size: pointSize, opacity: 1, force: CGFloat(event.pressure), azimuth: 0, altitude: 0)
    }
}





extension Color {
    var isDark: Bool {
        var r, g, b, a: CGFloat
        (r, g, b, a) = (0, 0, 0, 0)
        NSColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
        return luminance < 0.5
    }
}


// MARK: - Preview Provider

#Preview {
    DrawingView()
        .environmentObject(DrawingViewModel())
        .environmentObject(UserViewModel())
        .environmentObject(ColorMixingViewModel())
}
