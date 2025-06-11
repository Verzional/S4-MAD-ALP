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
        DotPuzzle(points: [
            CGPoint(x: 0.3, y: 0.5), // 1 - Nose
            CGPoint(x: 0.4, y: 0.4), // 2 - Forehead
            CGPoint(x: 0.6, y: 0.3), // 3 - Ear
            CGPoint(x: 0.7, y: 0.5), // 4 - Back of head
            CGPoint(x: 0.5, y: 0.7), // 5 - Chin
            CGPoint(x: 0.3, y: 0.5), // 6 - Back to nose
            CGPoint(x: 0.35, y: 0.55), // 7 - Mouth line
            CGPoint(x: 0.4, y: 0.6), // 8 - Lower jaw
            CGPoint(x: 0.5, y: 0.4), // 9 - Eye
            CGPoint(x: 0.6, y: 0.35) // 10 - Ear detail
        ]),
        DotPuzzle(points: [
            CGPoint(x: 0.5, y: 0.5), // 1 - Body center
            CGPoint(x: 0.3, y: 0.4), // 2 - Upper left wing
            CGPoint(x: 0.2, y: 0.6), // 3 - Lower left wing
            CGPoint(x: 0.5, y: 0.5), // 4 - Back to body
            CGPoint(x: 0.7, y: 0.4), // 5 - Upper right wing
            CGPoint(x: 0.8, y: 0.6), // 6 - Lower right wing
            CGPoint(x: 0.5, y: 0.5), // 7 - Back to body
            CGPoint(x: 0.5, y: 0.3), // 8 - Antenna left
            CGPoint(x: 0.5, y: 0.2), // 9 - Antenna tip
            CGPoint(x: 0.5, y: 0.3), // 10 - Back to base
            CGPoint(x: 0.5, y: 0.4)  // 11 - Head
        ]),
        DotPuzzle(points: [
            CGPoint(x: 0.3, y: 0.5), // 1 - Tail start
            CGPoint(x: 0.2, y: 0.4), // 2 - Tail top
            CGPoint(x: 0.2, y: 0.6), // 3 - Tail bottom
            CGPoint(x: 0.3, y: 0.5), // 4 - Back to tail
            CGPoint(x: 0.5, y: 0.4), // 5 - Dorsal fin
            CGPoint(x: 0.7, y: 0.5), // 6 - Head
            CGPoint(x: 0.5, y: 0.6), // 7 - Belly fin
            CGPoint(x: 0.3, y: 0.5), // 8 - Back to tail
            CGPoint(x: 0.6, y: 0.45), // 9 - Eye
            CGPoint(x: 0.8, y: 0.5)  // 10 - Mouth
        ]),
        DotPuzzle(points: [
            CGPoint(x: 0.5, y: 0.3), // 1 - Top head
            CGPoint(x: 0.3, y: 0.4), // 2 - Left ear
            CGPoint(x: 0.4, y: 0.6), // 3 - Left cheek
            CGPoint(x: 0.3, y: 0.7), // 4 - Left chin
            CGPoint(x: 0.7, y: 0.7), // 5 - Right chin
            CGPoint(x: 0.6, y: 0.6), // 6 - Right cheek
            CGPoint(x: 0.7, y: 0.4), // 7 - Right ear
            CGPoint(x: 0.5, y: 0.3), // 8 - Back to top
            CGPoint(x: 0.4, y: 0.5), // 9 - Left eye
            CGPoint(x: 0.6, y: 0.5), // 10 - Right eye
            CGPoint(x: 0.5, y: 0.6), // 11 - Nose
            CGPoint(x: 0.5, y: 0.7)  // 12 - Mouth
        ]),
        DotPuzzle(points: [
            CGPoint(x: 0.4, y: 0.7), // 1 - Bottom left
            CGPoint(x: 0.6, y: 0.7), // 2 - Bottom right
            CGPoint(x: 0.6, y: 0.4), // 3 - Top right
            CGPoint(x: 0.5, y: 0.2), // 4 - Roof peak
            CGPoint(x: 0.4, y: 0.4), // 5 - Top left
            CGPoint(x: 0.4, y: 0.7), // 6 - Back to start (close square)
            CGPoint(x: 0.5, y: 0.5), // 7 - Door top
            CGPoint(x: 0.5, y: 0.7), // 8 - Door bottom
        ])
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
