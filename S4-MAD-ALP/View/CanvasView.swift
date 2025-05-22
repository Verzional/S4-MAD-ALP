//
//  CanvasView 2.swift
//  S4-MAD-ALP
//
//  Created by student on 22/05/25.
//


//
//  CanvasView.swift
//  S4-MAD-ALP
//
//  Created by student on 22/05/25.
//

import SwiftUI

struct CanvasView: View {
    @ObservedObject var viewModel: CanvasViewModel
    
    var body: some View {
        VStack {
            GeometryReader { geo in
                Canvas { context, size in
                    for stroke in viewModel.strokes {
                        drawStroke(stroke, context: context)
                    }
                    
                    if let stroke = viewModel.currentStroke {
                        drawStroke(stroke, context: context, isCurrent: true)
                    }
                }
                .gesture(drawingGesture)
            }
            .background(Color.white)
            .border(Color.black.opacity(0.1))
            
            ColorPicker("Stroke Color", selection: $viewModel.strokeColor)
                .padding()
            
            Slider(value: $viewModel.strokeWidth, in: 1...20, step: 1, label: {
                Text("Line Width")
            })
            .padding()
        }
        .padding()
    }
    
    private func drawStroke(_ stroke: Stroke, context: GraphicsContext, isCurrent: Bool = false) {
        var path = Path()
        guard let firstPoint = stroke.points.first else { return }
        path.move(to: firstPoint)
        for point in stroke.points.dropFirst() {
            path.addLine(to: point)
        }
        context.stroke(path, with: .color(isCurrent ? stroke.color : stroke.color), lineWidth: stroke.lineWidth)
    }
    
    private var drawingGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if viewModel.currentStroke == nil {
                    viewModel.startStroke(at: value.location)
                } else {
                    viewModel.addPoint(value.location)
                }
            }
            .onEnded { _ in
                viewModel.endStroke()
            }
    }
}


#Preview {
    let vm = CanvasViewModel()
    CanvasView(viewModel: vm)
}

