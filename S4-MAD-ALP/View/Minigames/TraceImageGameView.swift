import SwiftUI

struct TraceImageGameView: View {
    @EnvironmentObject var cvm : DrawingViewModel
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
                    DrawingView()
                        .environmentObject(cvm)
                        .environmentObject(UserViewModel())
                        .environmentObject(ColorMixingViewModel())

                    Button("Finish") {
                        if cvm.drawing.bounds.isEmpty {
                            showingNoDrawingAlert = true // Show the alert if no drawing
                        } else {
                            userDrawnImage = Image(uiImage: cvm.drawing.image(from: cvm.drawing.bounds, scale: 1.0))
                                showingComparison = true
                            
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
        .onAppear{
            cvm.clear()
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
        .environmentObject(DrawingViewModel())
}
