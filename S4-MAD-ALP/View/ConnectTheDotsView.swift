import PencilKit
import SwiftUI

/// A simple data structure to define a single puzzle.
/// It contains a set of points in a normalized coordinate space (0.0 to 1.0).
struct DotPuzzle {
    let points: [CGPoint]
}

/// A view that hosts the "Connect the Dots" minigame.
struct ConnectTheDotsGameView: View {
    // MARK: - State Properties

    /// The core view model for managing the PencilKit canvas, injected from the environment.
    @EnvironmentObject var drawingViewModel: DrawingViewModel

    /// The list of available puzzles, now using normalized coordinates for responsiveness.
    private let puzzles = [
        DotPuzzle(points: [ // A simple house shape
            CGPoint(x: 0.2, y: 0.8), CGPoint(x: 0.8, y: 0.8),
            CGPoint(x: 0.8, y: 0.4), CGPoint(x: 0.5, y: 0.1),
            CGPoint(x: 0.2, y: 0.4), CGPoint(x: 0.2, y: 0.8),
        ]),
        DotPuzzle(points: [ // A star shape
            CGPoint(x: 0.5, y: 0.1), CGPoint(x: 0.65, y: 0.4),
            CGPoint(x: 0.95, y: 0.4), CGPoint(x: 0.7, y: 0.6),
            CGPoint(x: 0.8, y: 0.9), CGPoint(x: 0.5, y: 0.7),
            CGPoint(x: 0.2, y: 0.9), CGPoint(x: 0.3, y: 0.6),
            CGPoint(x: 0.05, y: 0.4), CGPoint(x: 0.35, y: 0.4),
            CGPoint(x: 0.5, y: 0.1),
        ]),
        DotPuzzle(points: [
                    CGPoint(x: 0.5, y: 0.1), CGPoint(x: 0.3, y: 0.2),  // Ear
                    CGPoint(x: 0.3, y: 0.4), CGPoint(x: 0.4, y: 0.5),  // Head
                    CGPoint(x: 0.2, y: 0.6), CGPoint(x: 0.2, y: 0.9),  // Back and leg
                    CGPoint(x: 0.8, y: 0.9), CGPoint(x: 0.8, y: 0.6),  // Front legs
                    CGPoint(x: 0.6, y: 0.5), CGPoint(x: 0.7, y: 0.4),  // Chest and other ear
                    CGPoint(x: 0.7, y: 0.2), CGPoint(x: 0.5, y: 0.1),  // Complete head
                ]),
                // Puzzle: A simple dog profile
                DotPuzzle(points: [
                    CGPoint(x: 0.2, y: 0.4), CGPoint(x: 0.1, y: 0.5),  // Nose
                    CGPoint(x: 0.2, y: 0.6), CGPoint(x: 0.4, y: 0.55), // Jaw
                    CGPoint(x: 0.35, y: 0.3), CGPoint(x: 0.5, y: 0.2), // Head
                    CGPoint(x: 0.6, y: 0.3), CGPoint(x: 0.55, y: 0.5), // Ear
                    CGPoint(x: 0.7, y: 0.45), CGPoint(x: 0.9, y: 0.5), // Back and tail
                    CGPoint(x: 0.85, y: 0.8), CGPoint(x: 0.75, y: 0.8),// Back legs
                    CGPoint(x: 0.5, y: 0.75), CGPoint(x: 0.4, y: 0.8), // Belly and front leg
                    CGPoint(x: 0.3, y: 0.8), CGPoint(x: 0.2, y: 0.6),  // Front chest
                ]),
                // Puzzle: A simple fish
                DotPuzzle(points: [
                    CGPoint(x: 0.1, y: 0.5), CGPoint(x: 0.3, y: 0.3), // Mouth and top
                    CGPoint(x: 0.7, y: 0.4), CGPoint(x: 0.9, y: 0.2), // To tail
                    CGPoint(x: 0.8, y: 0.5), CGPoint(x: 0.9, y: 0.8), // Tail fin
                    CGPoint(x: 0.7, y: 0.6), CGPoint(x: 0.3, y: 0.7), // Bottom
                    CGPoint(x: 0.1, y: 0.5),                          // Back to start
                ]),
    ]

    /// The currently active puzzle.
    @State private var currentPuzzle: DotPuzzle

    /// Tracks the index of the last dot successfully connected. Starts at 0.
    @State private var lastConnectedDotIndex = 0

    /// Controls whether the "You Win!" overlay is visible.
    @State private var gameWon = false

    /// Initializes the view and selects a random puzzle to start.
    init() {
        _currentPuzzle = State(initialValue: puzzles.randomElement() ?? puzzles[0])
    }

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
                        CanvasViewWrapper()
                            .environmentObject(drawingViewModel)
                            .background(Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                            )
                        
                        // The overlay with dots, now drawn on top and scaled to the canvas size.
                        DotsOverlayView(
                            puzzle: currentPuzzle,
                            lastConnectedDotIndex: lastConnectedDotIndex,
                            size: canvasSize
                        )
                    }
                    // This is the core logic. It checks the drawing every time it changes.
                    .onChange(of: drawingViewModel.drawing) { newDrawing in
                        checkUserDrawing(newDrawing, in: canvasSize)
                    }
                }
                .padding(.horizontal)

                // Drawing Tools
                toolPickerSection
                    .padding(.horizontal)
            }
            .padding(.bottom)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .disabled(gameWon) // Disable drawing when the game is won.

            // "You Win!" Overlay
            if gameWon {
                GameWonView(onPlayAgain: resetGame)
            }
        }
    }

    // MARK: - Game Logic

    /// Checks the last stroke drawn by the user to see if it connects the correct dots within the given size.
    private func checkUserDrawing(_ newDrawing: PKDrawing, in size: CGSize) {
        guard let lastStroke = newDrawing.strokes.last else { return }

        // Ensure there are more dots to connect.
        guard lastConnectedDotIndex < currentPuzzle.points.count - 1 else { return }

        // Get the start and end points of the line the user just drew.
        guard let strokeStartPoint = lastStroke.path.first?.location,
              let strokeEndPoint = lastStroke.path.last?.location else { return }

        // Define the two dots that need to be connected next, converting their normalized
        // coordinates to absolute coordinates within the canvas size.
        let correctStartDot = absolutePoint(for: currentPuzzle.points[lastConnectedDotIndex], in: size)
        let correctEndDot = absolutePoint(for: currentPuzzle.points[lastConnectedDotIndex + 1], in: size)

        // Check if the stroke connects the dots in the correct order.
        if isClose(point1: strokeStartPoint, point2: correctStartDot, threshold: 40) &&
           isClose(point1: strokeEndPoint, point2: correctEndDot, threshold: 40) {

            // Success! Update the state to connect the next dot.
            lastConnectedDotIndex += 1

            // Check for win condition.
            if lastConnectedDotIndex >= currentPuzzle.points.count - 1 {
                withAnimation {
                    gameWon = true
                }
            }
        }
    }

    /// Resets the game to a new, random puzzle.
    private func resetGame() {
        drawingViewModel.clear()
        currentPuzzle = puzzles.randomElement() ?? puzzles[0]
        lastConnectedDotIndex = 0
        withAnimation {
            gameWon = false
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

    // MARK: - UI Components

    /// A simple section for selecting drawing tools.
    private var toolPickerSection: some View {
        HStack(spacing: 20) {
            toolButton(icon: "pencil.tip", color: .blue) { drawingViewModel.usePen() }
            toolButton(icon: "eraser", color: .red) { drawingViewModel.useSoftEraser() }
            Spacer()
            Button("Clear") {
                drawingViewModel.clear()
                lastConnectedDotIndex = 0 // Reset progress if cleared
            }
            .padding(.horizontal)
        }
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
                Text("You Win!")
                    .font(.system(size: 50, weight: .bold, design: .rounded))
                    .foregroundColor(.green)

                Button(action: onPlayAgain) {
                    Label("Play Again", systemImage: "arrow.clockwise.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(15)
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

// These helper views for the canvas would be in their own files in a real project.
private struct CanvasViewWrapper: UIViewControllerRepresentable {
    @EnvironmentObject var viewModel: DrawingViewModel

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let canvasView = PKCanvasView()
        canvasView.drawingPolicy = .anyInput
        canvasView.delegate = context.coordinator
        canvasView.tool = viewModel.tool
        canvasView.drawing = viewModel.drawing
        canvasView.backgroundColor = .clear
        
        let viewController = UIViewController()
        viewController.view.addSubview(canvasView)
        canvasView.frame = viewController.view.bounds
        canvasView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        context.coordinator.canvasView = canvasView
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        guard let canvasView = context.coordinator.canvasView else { return }
        canvasView.tool = viewModel.tool
        if canvasView.drawing != viewModel.drawing {
            canvasView.drawing = viewModel.drawing
        }
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        var viewModel: DrawingViewModel
        weak var canvasView: PKCanvasView?

        init(viewModel: DrawingViewModel) {
            self.viewModel = viewModel
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            DispatchQueue.main.async { [weak self] in
                self?.viewModel.drawing = canvasView.drawing
            }
        }
    }
}


// MARK: - Preview
#Preview {
    ConnectTheDotsGameView()
        .environmentObject(DrawingViewModel())
}
