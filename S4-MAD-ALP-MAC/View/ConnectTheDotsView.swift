import PencilKit
import SwiftUI

struct ConnectTheDotsGameView: View {

    @EnvironmentObject var drawingViewModel: DrawingViewModel
    @EnvironmentObject var uvm: UserViewModel
    @StateObject var connectTheDotsViewModel: ConnectTheDotsViewModel = ConnectTheDotsViewModel()
    @State private var showingColorPickerSheet = false
    

    // MARK: - Body
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                // Header
                Text("Connect the Dots!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                // Canvas Area - Use GeometryReader to get the available size for the canvas.
                GeometryReader { geometry in
                    let canvasSize = geometry.size
                    ZStack {
                        // The PencilKit canvas where the user draws.
                        EditableCanvasView(drawing: drawingViewModel.drawing, tool: $drawingViewModel.tool)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(radius: 3)
                            .layoutPriority(1)
                            .environmentObject(drawingViewModel)
                            .environmentObject(drawingViewModel)
                            .background(Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                            )
                        
                        // The overlay with dots, now drawn on top and scaled to the canvas size.
                        DotsOverlayView(
                            puzzle: connectTheDotsViewModel.currentPuzzle,
                            lastConnectedDotIndex: connectTheDotsViewModel.lastConnectedDotIndex,
                            size: canvasSize
                        )
                    }
                    
                    .onChange(of: drawingViewModel.drawing) { newDrawing in
                        connectTheDotsViewModel.checkUserDrawing(newDrawing, in: canvasSize)
                        
                        if connectTheDotsViewModel.gameWon == true {
                                        uvm.gainXP(xp: 100)
                            drawingViewModel.clear()
                                    }
                    }
                }
                .padding(.horizontal)

                // Drawing Tools
                toolPickerSection
                    .padding(.horizontal)
                
                HStack{
                    brushSizeSection
                    
                    Button(action: {
                        showingColorPickerSheet = true
                    }) {
                        Circle()
                            .fill(drawingViewModel.strokeColor)
                            .frame(width: 44, height: 44)
                            .overlay(
                                Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                            .overlay(
                                Image(systemName: "paintpalette.fill")
                                    .foregroundColor(drawingViewModel.strokeColor.isDark ? .white : .black)
                                    .font(.system(size: 20))
                            )
                            .shadow(radius: 2)
                    }
                }.padding(.horizontal)
                
            }
            .padding(.bottom)
            .background(Color(.gray).ignoresSafeArea())
            .disabled(connectTheDotsViewModel.gameWon)
            .sheet(isPresented: $showingColorPickerSheet) {
                ColorPickerSheetView(onColorSelect: { selectedColorItem in
                    drawingViewModel.strokeColor = Color(hex: selectedColorItem.hex)
                    drawingViewModel.updateToolColorOrWidth()
                    showingColorPickerSheet = false
                })
                .environmentObject(drawingViewModel)
            }

            
            if connectTheDotsViewModel.gameWon {
                
                GameWonView(onPlayAgain: connectTheDotsViewModel.resetGame)
            }
        }.onAppear(){
            drawingViewModel.levelCheck(level: uvm.userModel.level)
        }
        
        
    }

    

    
    // MARK: - Helper Functions

    private func absolutePoint(for normalizedPoint: CGPoint, in size: CGSize) -> CGPoint {
        return CGPoint(x: normalizedPoint.x * size.width, y: normalizedPoint.y * size.height)
    }

    
    private func isClose(point1: CGPoint, point2: CGPoint, threshold: CGFloat) -> Bool {
        let distance = sqrt(pow(point1.x - point2.x, 2) + pow(point1.y - point2.y, 2))
        return distance < threshold
    }

    private func toolButton(icon: String, toolType: DrawingViewModel.DrawingToolType, action: @escaping () -> Void) -> some View {
        let isSelected = drawingViewModel.currentTool == toolType
        let isDisabled: Bool
        switch toolType {
        case .pencil: isDisabled = !drawingViewModel.pencilEnabled
        case .marker: isDisabled = !drawingViewModel.markerEnabled
        case .crayon: isDisabled = !drawingViewModel.crayonEnabled
        default: isDisabled = false
        }
        
        return Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isDisabled ? .gray : (isSelected ? Color.white : Color.accentColor))
                .frame(width: 44, height: 44)
                .background(isSelected ? Color.accentColor : Color(.gray))
                .clipShape(Circle())
                .shadow(radius: isSelected ? 3 : 1)
        }
        .disabled(isDisabled)
    }
    
    private var brushSizeSection: some View {
        HStack(spacing: 10) {
            Image(systemName: "circle.fill")
                .font(.system(size: 8))
                .foregroundColor(.gray)
            
            Slider(value: $drawingViewModel.strokeWidth, in: 1...30, step: 1) {
                Text("Brush Size")
            }
            .tint(drawingViewModel.strokeColor)
            .onChange(of: drawingViewModel.strokeWidth) { _ in
                drawingViewModel.updateToolColorOrWidth()
            }
            
            Image(systemName: "circle.fill")
                .font(.system(size: 20))
                .foregroundColor(.gray)
            
            Text("\(Int(drawingViewModel.strokeWidth))pt")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 40, alignment: .trailing)
        }
    }
    
    private var toolPickerSection: some View {
        HStack(spacing: 12) {
            toolButton(icon: "pencil.tip", toolType: .pen, action: drawingViewModel.usePen)
            toolButton(icon: "pencil", toolType: .pencil, action: drawingViewModel.usePencil)
            toolButton(icon: "paintbrush.pointed", toolType: .marker, action: drawingViewModel.useMarker)
            toolButton(icon: "highlighter", toolType: .crayon, action: drawingViewModel.useCrayon)
            Spacer()
            toolButton(icon: "eraser", toolType: .softEraser, action: drawingViewModel.useSoftEraser)
            toolButton(icon: "scissors", toolType: .strokeEraser, action: drawingViewModel.useStrokeEraser)
        }
        .padding(.vertical, 5)
    }

    /// A reusable button for the tool picker.
    private func toolButton(icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(color)
                .clipShape(Circle())
        }
    }
}

// MARK: - Helper Views

/// A view that draws the dots and the successful connection lines on the screen.
struct DotsOverlayView: View {
    let puzzle: DotPuzzle
    let lastConnectedDotIndex: Int
    let size: CGSize // The size of the parent canvas to scale points correctly.

    /// Converts a normalized point to an absolute point within the view's size.
    private func absolutePoint(for normalizedPoint: CGPoint) -> CGPoint {
        return CGPoint(x: normalizedPoint.x * size.width, y: normalizedPoint.y * size.height)
    }

    var body: some View {
        ZStack {
            // Draw lines for already connected dots
            Path { path in
                guard lastConnectedDotIndex > 0 else { return }
                for i in 0...lastConnectedDotIndex {
                    let point = absolutePoint(for: puzzle.points[i])
                    if i == 0 {
                        path.move(to: point)
                    } else {
                        path.addLine(to: point)
                    }
                }
            }
            .stroke(Color.green, lineWidth: 5)
            .opacity(0.6)

            // Draw all the dots
            ForEach(Array(puzzle.points.enumerated()), id: \.offset) { index, normalizedPoint in
                let isCompleted = index < lastConnectedDotIndex
                let isCurrentStart = index == lastConnectedDotIndex
                let dotColor: Color = isCompleted ? .green : (isCurrentStart ? .yellow : .gray.opacity(0.7))

                ZStack {
                    Circle()
                        .fill(dotColor)
                        .frame(width: 40, height: 40)
                        .shadow(radius: 2)

                    Text("\(index + 1)")
                        .foregroundColor(.white)
                        .font(.headline)
                        .fontWeight(.bold)
                }
                .position(absolutePoint(for: normalizedPoint))
            }
        }
        .allowsHitTesting(false) // Allows drawing "through" this view onto the canvas below
    }
}

/// A view that appears when the game is won, prompting the user to play again.
struct GameWonView: View {
    var onPlayAgain: () -> Void

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 20) {
                Text("Congratulations")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    
                HStack{
                    Button(action: onPlayAgain) {
                        Label("Play Again", systemImage: "arrow.clockwise.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(15)
                    }
                    
                    Button(action:{
                        
                    }){
                        
                    }
                }
                
            }
            .padding(30)
            .background(.thinMaterial)
            .cornerRadius(20)
            .shadow(radius: 10)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.4))
        .transition(.opacity)
    }
}




// MARK: - Preview
#Preview {
    ConnectTheDotsGameView()
        .environmentObject(DrawingViewModel())
        .environmentObject(UserViewModel())
        .environmentObject(ConnectTheDotsViewModel())
    
}
