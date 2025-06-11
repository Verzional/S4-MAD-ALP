import PencilKit
import SwiftUI

struct TraceImageGameView: View {
    struct CanvasSizePreferenceKey: PreferenceKey {
        static var defaultValue: CGSize = .zero
        static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
            value = nextValue()
        }
    }
    // Environment and State
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var userDrawnImage: Image?
    @State private var currentImageKey: String
    @State private var currentImageName: String
    @State private var showingNoDrawingAlert = false
    @State private var drawingFinished = false
    @StateObject var cvm = DrawingViewModel() // Canvas ViewModel
    @EnvironmentObject var uvm: UserViewModel // User ViewModel
    @State private var showingColorPickerSheet = false
    @State private var canvasSize: CGSize = .zero // State to hold the measured canvas size

    // Initializer to select a random image
    init() {
        let randomImage = imageNameMap.randomElement()
        _currentImageKey = State(initialValue: randomImage?.key ?? "2")
        _currentImageName = State(initialValue: randomImage?.value ?? "Apple")
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            if !drawingFinished {
                // **THE FIX**: This VStack provides a robust layout for macOS.
                VStack(spacing: 15) {
                    // Header (fixed height)
                    Text("Draw \(currentImageName)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)

                    // Canvas area that fills all remaining flexible space.
                    GeometryReader { geometry in
                        ZStack {
                            EditableCanvasView(
                                drawing: cvm.drawing,
                                tool: $cvm.tool
                            )
                            .environmentObject(cvm)
                            .background(Color.clear)
                           
                            .onAppear { self.canvasSize = geometry.size }
                            .onChange(of: geometry.size) { newSize in
                                self.canvasSize = newSize
                            }
                            Image(currentImageKey)
                                .resizable()
                                .scaledToFit()
                                .opacity(0.3)
                            
                            // The actual drawing canvas.
                           
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)
                    
                    // Controls (fixed height) are placed last.
                    VStack(spacing: 15) {
                        toolPickerSection
                        brushSizeSection
                        finishButton(imageSize: self.canvasSize)
                    }
                    .padding([.horizontal, .bottom])
                }
            } else {
                // View shown after the user finishes drawing
                resultsView(imageSize: self.canvasSize)
            }
        }
        .background(Color(.windowBackgroundColor).ignoresSafeArea())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            cvm.levelCheck(level: uvm.userModel.level)
        }
        .sheet(isPresented: $showingColorPickerSheet) {
             // ColorPickerSheetView would be presented here.
        }
    }

    // MARK: - UI Components
    private func finishButton(imageSize: CGSize) -> some View {
        Button {
            guard imageSize != .zero else {
                // Prevent capture if size is not yet determined.
                showingNoDrawingAlert = true
                return
            }
            if cvm.drawing.strokes.isEmpty {
                showingNoDrawingAlert = true
            } else {
                let imageRect = CGRect(origin: .zero, size: imageSize)
                let originalImage = cvm.drawing.image(from: imageRect, scale: 2.0)
                
                if let flippedImage = originalImage.flipped() {
                    userDrawnImage = Image(nsImage: flippedImage)
                } else {
                    userDrawnImage = Image(nsImage: originalImage) // Fallback
                }
                
                drawingFinished = true
            }
        } label: {
            Text("Finish")
                .frame(maxWidth: .infinity)
                .padding()
                .background(LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing))
                .foregroundColor(.white)
                .cornerRadius(12)
                .font(.headline)
        }
        .alert(isPresented: $showingNoDrawingAlert) {
            Alert(
                title: Text("No Drawing"),
                message: Text("Please draw something before finishing."),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    @ViewBuilder
    private func resultsView(imageSize: CGSize) -> some View {
        VStack {
            Text("The Result")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.vertical)

            ZStack {
                Image(currentImageKey)
                    .resizable()
                    .scaledToFit()
                    .opacity(0.3)
                
                if let finalImage = userDrawnImage {
                    finalImage
                        .resizable()
                        .scaledToFit()
                } else {
                    Text("No drawing captured.")
                }
            }
            .frame(width: imageSize.width, height: imageSize.height)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
            .padding(.horizontal)

            Spacer()

            Button("Play Again") {
                resetGame()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing))
            .foregroundColor(.white)
            .cornerRadius(12)
            .font(.headline)
            .padding()
        }
    }

    private func resetGame() {
        cvm.clear()
        userDrawnImage = nil
        drawingFinished = false
        
        let randomImage = imageNameMap.randomElement()
        currentImageKey = randomImage?.key ?? "2"
        currentImageName = randomImage?.value ?? "Apple"
        
        cvm.strokeColor = .black
        cvm.strokeWidth = 10.0
        cvm.usePen()
    }
    
    // MARK: - Tool UI Subviews
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
    }
    
    private var brushSizeSection: some View {
        HStack(spacing: 15) {
            HStack {
                Image(systemName: "circle.fill")
                    .font(.system(size: 8))
                    .foregroundColor(.gray)
                
                Slider(value: $cvm.strokeWidth, in: 1...50, step: 1)
                .tint(cvm.strokeColor)
                .onChange(of: cvm.strokeWidth) { _ in
                    cvm.updateToolColorOrWidth()
                }
                
                Image(systemName: "circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.gray)
            }
            
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
    }
}

extension NSImage {
    func flipped() -> NSImage? {
        let newImage = NSImage(size: self.size)
        newImage.lockFocus()
        
        let transform = NSAffineTransform()
        transform.translateX(by: 0, yBy: self.size.height)
        transform.scaleX(by: 1, yBy: -1)
        
        transform.concat()
        
        self.draw(at: .zero, from: NSRect(origin: .zero, size: self.size), operation: .sourceOver, fraction: 1.0)
        
        newImage.unlockFocus()
        return newImage
    }
}




#Preview {
    TraceImageGameView()
        .environmentObject(DrawingViewModel())
        .environmentObject(UserViewModel())
}
