import PencilKit
import SwiftUI

struct DotPuzzle {
    let points: [CGPoint]
}

class ConnectTheDotsViewModel: ObservableObject {
    @Published var currentPuzzle: DotPuzzle
    @Published var lastConnectedDotIndex = 0
    @Published var gameWon = false

    private let puzzles = [
        DotPuzzle(points: [
            CGPoint(x: 0.5, y: 0.1), CGPoint(x: 0.3, y: 0.2),
            CGPoint(x: 0.3, y: 0.4), CGPoint(x: 0.4, y: 0.5),
            CGPoint(x: 0.2, y: 0.6), CGPoint(x: 0.2, y: 0.9),
            CGPoint(x: 0.8, y: 0.9), CGPoint(x: 0.8, y: 0.6),
            CGPoint(x: 0.6, y: 0.5), CGPoint(x: 0.7, y: 0.4),
            CGPoint(x: 0.7, y: 0.2), CGPoint(x: 0.5, y: 0.1),
        ]),
        DotPuzzle(points: [
            CGPoint(x: 0.2, y: 0.4), CGPoint(x: 0.1, y: 0.5),
            CGPoint(x: 0.2, y: 0.6), CGPoint(x: 0.4, y: 0.55),
            CGPoint(x: 0.35, y: 0.3), CGPoint(x: 0.5, y: 0.2),
            CGPoint(x: 0.6, y: 0.3), CGPoint(x: 0.55, y: 0.5),
            CGPoint(x: 0.7, y: 0.45), CGPoint(x: 0.9, y: 0.5),
            CGPoint(x: 0.85, y: 0.8), CGPoint(x: 0.75, y: 0.8),
            CGPoint(x: 0.5, y: 0.75), CGPoint(x: 0.4, y: 0.8),
            CGPoint(x: 0.3, y: 0.8), CGPoint(x: 0.2, y: 0.6),
        ]),
        DotPuzzle(points: [
            CGPoint(x: 0.1, y: 0.5), CGPoint(x: 0.3, y: 0.3),
            CGPoint(x: 0.7, y: 0.4), CGPoint(x: 0.9, y: 0.2),
            CGPoint(x: 0.8, y: 0.5), CGPoint(x: 0.9, y: 0.8),
            CGPoint(x: 0.7, y: 0.6), CGPoint(x: 0.3, y: 0.7),
            CGPoint(x: 0.1, y: 0.5),
        ]),
    ]

    init() {
        self.currentPuzzle = puzzles.randomElement() ?? puzzles[0]
    }

    func checkUserDrawing(_ newDrawing: PKDrawing, in size: CGSize) {
        guard let lastStroke = newDrawing.strokes.last else { return }
        guard lastConnectedDotIndex < currentPuzzle.points.count - 1 else { return }
        guard let strokeStartPoint = lastStroke.path.first?.location,
              let strokeEndPoint = lastStroke.path.last?.location else { return }

        let correctStartDot = absolutePoint(for: currentPuzzle.points[lastConnectedDotIndex], in: size)
        let correctEndDot = absolutePoint(for: currentPuzzle.points[lastConnectedDotIndex + 1], in: size)

        if isClose(point1: strokeStartPoint, point2: correctStartDot, threshold: 40) &&
           isClose(point1: strokeEndPoint, point2: correctEndDot, threshold: 40) {
            
            lastConnectedDotIndex += 1
            
            if lastConnectedDotIndex >= currentPuzzle.points.count - 1 {
                withAnimation {
                    gameWon = true
                }
            }
        }
    }

    func resetGame() {
        currentPuzzle = puzzles.randomElement() ?? puzzles[0]
        lastConnectedDotIndex = 0
        withAnimation {
            gameWon = false
        }
    }
    
    private func absolutePoint(for normalizedPoint: CGPoint, in size: CGSize) -> CGPoint {
        return CGPoint(x: normalizedPoint.x * size.width, y: normalizedPoint.y * size.height)
    }

    private func isClose(point1: CGPoint, point2: CGPoint, threshold: CGFloat) -> Bool {
        let distance = sqrt(pow(point1.x - point2.x, 2) + pow(point1.y - point2.y, 2))
        return distance < threshold
    }
}
