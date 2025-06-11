import PencilKit
import SwiftUI

struct MemoryGameView: View {
    @EnvironmentObject var cvm: DrawingViewModel
    @EnvironmentObject var uvm: UserViewModel
    @State private var currentStroke = Stroke()
    @State private var strokes: [Stroke] = []
    @State private var isImageVisible = true
    @State private var showingComparison = false
    @State private var userDrawnImage: Image?
    @State private var countdown: Int = 3
    @State private var currentImageName: String
    @State private var selectedColor: Color = .black
    @State private var showingNoDrawingAlert = false // New state for the alert
    @State private var showingColorPickerSheet = false
    
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
                GeometryReader{ geometry in
                VStack {
                    
                        let canvasSize = min(geometry.size.width, geometry.size.height)

                        
                        Text("Draw")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.bottom, 20)
                        
                        CanvasViewWrapper()
                            .environmentObject(cvm)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(radius: 3)
                            .layoutPriority(1)
                            .padding()
                        
                        
                        Spacer()
                        //spacingnya ini untuk jarak antar viewnya
                        toolPickerSection
                            .padding(.horizontal)
                        
                        HStack(spacing: 15) {
                            
                            brushSizeSection
                            
                            Button(action: {
                                showingColorPickerSheet = true
                            }) {
                                Circle()
                                    .fill(cvm.strokeColor)
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                    )
                                    .overlay(
                                        Image(systemName: "paintpalette.fill")
                                            .foregroundColor(cvm.strokeColor.isDark ? .white : .black)
                                            .font(.system(size: 20))
                                    )
                                    .shadow(radius: 2)
                            }
                            
                            
                            
                        }.padding(.horizontal)
                        
                        Button("Finish") {
                            if cvm.drawing.strokes.isEmpty {
                                showingNoDrawingAlert = true // Show the alert if no drawing
                            } else {
                                let uiImage = cvm.drawing.image(
                                    from: CGRect(
                                        x: 0,
                                        y: 0,
                                        width: canvasSize*0.85,
                                        height: canvasSize
                                    ),
                                    scale: UIScreen.main.scale
                                )
                                // disini nanti Image dari PKDrawing itu diubah menjadi komponen SwiftUI
                                userDrawnImage = Image(uiImage: uiImage)
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
            }
            
            if showingComparison {
                comparisonView
            }
        }.onAppear(){
            cvm.clear()
        }
    }
    
    @ViewBuilder
    private var comparisonView: some View {
        VStack {
            Text("Your Drawing:")
                .font(.headline)
            if let finalImage = userDrawnImage {
                finalImage
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: 240,
                        height: 300
                    )
                    .border(Color.blue, width: 1)
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
                
                cvm.clear()
            }
            .padding()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
    // the color palette
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
                .background(isSelected ? Color.accentColor : Color(.systemGray5))
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
            .onChange(of: cvm.strokeWidth) { _ in
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

// the canvas
//UIViewController ini bawaan dari swiftUInya, nah biar bisa ditampilin di view, hrus di wrap dulu
private struct CanvasViewWrapper: UIViewControllerRepresentable {
    
    //buat manggil object dari viewmodel, pake environment krn kyk dipanggil panggil ke bbrp view
    @EnvironmentObject var cvm: DrawingViewModel
    
    //coordinator ini gunanya buat jadi jembatan antara swiftUI sama UIKit
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: cvm)
    }
    
    //Untuk membuat instance dari UIKit ViewController yang akan ditampilkan di SwiftUI
    func makeUIViewController(context: Context) -> UIViewController {
        
        //instance dari PKCanvasView disimpen dalam canvasView as object
        let canvasView = PKCanvasView()
        
        // part of PencilKi
        canvasView.drawingPolicy = .anyInput
        canvasView.delegate = context.coordinator
        //ngambil ke cvm tool-toolnya
        canvasView.tool = cvm.tool
        //ngambil PKDrawingnya dri cvm
        canvasView.drawing = cvm.drawing
        canvasView.backgroundColor = .clear
        
        let viewController = UIViewController()
        viewController.view.addSubview(canvasView)
        canvasView.frame = viewController.view.bounds
        canvasView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        context.coordinator.canvasView = canvasView
        return viewController
    }
    
    //Sinkronisasi dari SwiftUI ke UIKit saat ada perubahan state, ini bakalan automaticallly update si kalau ada perubahan yang dilakuin di canvasnya (PKDrawing)
    func updateUIViewController(
        _ uiViewController: UIViewController,
        context: Context
    ) {
        guard let canvasView = context.coordinator.canvasView else { return }
        canvasView.tool = cvm.tool
        if canvasView.drawing != cvm.drawing {
            canvasView.drawing = cvm.drawing
        }
    }
    
    // disini di koordinasiin, biar bisa tau user tu mulai sama selesainya kapan
    class Coordinator: NSObject, PKCanvasViewDelegate {
        let cvm: DrawingViewModel
        weak var canvasView: PKCanvasView?
        
        init(viewModel: DrawingViewModel) {
            self.cvm = viewModel
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            cvm.drawing = canvasView.drawing
        }
    }
}




#Preview {
    MemoryGameView()
        .environmentObject(DrawingViewModel())
        .environmentObject(UserViewModel())
}
