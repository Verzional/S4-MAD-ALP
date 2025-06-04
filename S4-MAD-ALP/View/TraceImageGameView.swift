import SwiftUI

struct TraceImageGameView: View {
    @State private var currentStroke = Stroke()
    @State private var strokes: [Stroke] = []
    @State private var isImageVisible = true
    @State private var showingComparison = false
    @State private var userDrawnImage: Image?
    @State private var countdown: Int = 3
    @State private var currentImageName: String
    @State private var selectedColor: Color = .black
    @State private var showingNoDrawingAlert = false // New state for the alert

    let canvasWidth: CGFloat = 400
    let canvasHeight: CGFloat = 500
    let allImageNames = (2...26).map { String($0) }
    let availableColors: [Color] = [.black, .red, .blue, .green, .yellow, .orange]

    init() {
        _currentImageName = State(initialValue: allImageNames.randomElement() ?? "2")
    }

    var body: some View {
        ZStack {
            if isImageVisible {
                VStack {
                    Text("Memorize: \(countdown)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 20)

                    Image(currentImageName)
                        .resizable()
                        .scaledToFit()
                        .opacity(1.0)
                        .frame(width: canvasWidth, height: canvasHeight)
                        .onAppear {
                            countdown = 3
                            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                                if self.countdown > 0 {
                                    self.countdown -= 1
                                } else {
                                    timer.invalidate()
                                    withAnimation {
                                        isImageVisible = false
                                    }
                                }
                            }
                        }
                }
            } else {
                VStack {
                    Text("Draw")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 20)

                    Canvas { context, size in
                        for stroke in strokes {
                            var path = Path()
                            path.addLines(stroke.points)
                            context.stroke(path, with: .color(stroke.color), lineWidth: stroke.lineWidth)
                        }
                        var path = Path()
                        path.addLines(currentStroke.points)
                        context.stroke(path, with: .color(currentStroke.color), lineWidth: currentStroke.lineWidth)
                    }
                    .frame(width: canvasWidth, height: canvasHeight)
                    .border(Color.black, width: 1)
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .local)
                            .onChanged({ value in
                                let newPoint = value.location
                                currentStroke.points.append(newPoint)
                                currentStroke.color = selectedColor
                            })
                            .onEnded({ _ in
                                strokes.append(currentStroke)
                                currentStroke = Stroke(color: selectedColor)
                            })
                    )

                    HStack {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(availableColors, id: \.self) { color in
                                    Circle()
                                        .fill(color)
                                        .frame(width: 30, height: 30)
                                        .overlay(
                                            Circle()
                                                .strokeBorder(Color.gray, lineWidth: selectedColor == color ? 2 : 0)
                                        )
                                        .onTapGesture {
                                            selectedColor = color
                                        }
                                }
                            }
                        }

                        ColorPicker("", selection: $selectedColor)
                            .frame(width: 50, height: 30)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)

                    Button("Finish") {
                        if strokes.isEmpty {
                            showingNoDrawingAlert = true // Show the alert if no drawing
                        } else {
                            let renderer = ImageRenderer(content:
                                Canvas { context, size in
                                    for stroke in strokes {
                                        var path = Path()
                                        path.addLines(stroke.points)
                                        context.stroke(path, with: .color(stroke.color), lineWidth: stroke.lineWidth)
                                    }
                                }
                                .frame(width: canvasWidth, height: canvasHeight)
                            )
                            if let uiImage = renderer.uiImage {
                                userDrawnImage = Image(uiImage: uiImage)
                                showingComparison = true
                            }
                        }
                    }
                    .padding()
                    .alert(isPresented: $showingNoDrawingAlert) { // Define the alert
                        Alert(
                            title: Text("No Drawing"),
                            message: Text("Please draw something before finishing."),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
            }

            if showingComparison {
                comparisonView
            }
        }
    }

    @ViewBuilder
    private var comparisonView: some View {
        VStack {
            Text("Your Drawing:")
                .font(.headline)
            if let userDrawnImage {
                userDrawnImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 240, height: 300)
                    .border(Color.gray, width: 1)
            } else {
                Text("No drawing captured.")
            }

            Text("Original Image:")
                .font(.headline)
                .padding(.top)
            Image(currentImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 240, height: 300)
                .border(Color.gray, width: 1)

            Button("Play Again") {
                strokes = []
                isImageVisible = true
                showingComparison = false
                userDrawnImage = nil
                countdown = 3
                currentImageName = allImageNames.randomElement() ?? "2"
                selectedColor = .black
            }
            .padding()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

#Preview {
    TraceImageGameView()
}
