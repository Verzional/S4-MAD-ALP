import PencilKit
import SwiftUI

// MARK: - Trace Image Game View
struct TraceImageGameView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var userDrawnImage: Image?
    @State private var currentImageKey: String
    @State private var currentImageName: String
    @State private var showingNoDrawingAlert = false
    @State private var drawingFinished = false
    @StateObject var drawingVM = DrawingViewModel()

    // MARK: - Initialization
    init() {
        let randomImage = imageNameMap.randomElement()
        _currentImageKey = State(initialValue: randomImage?.key ?? "2")
        _currentImageName = State(initialValue: randomImage?.value ?? "Apple")
        print(
            "Initial currentImageKey: \(currentImageKey), Initial currentImageName: \(currentImageName)"
        )
    }

    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            let maxCanvasSize = min(geometry.size.width, geometry.size.height)
            let canvasSize =
                maxCanvasSize * (horizontalSizeClass == .regular ? 0.85 : 0.9)

            ZStack {
                if !drawingFinished {
                    VStack {
                        // Header
                        HStack {
                            Text("Draw \(currentImageName)")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.horizontal, 20)
                        }
                        .padding(.horizontal)

                        // Canvas + Trace Image
                        ZStack {
                            Image(currentImageKey)
                                .resizable()
                                .scaledToFit()
                                .opacity(0.3)
                                .frame(width: canvasSize, height: canvasSize)

                            CanvasViewWrapper()
                                .environmentObject(drawingVM)
                                .frame(width: canvasSize, height: canvasSize)
                                .aspectRatio(1, contentMode: .fit)
                                .background(Color.clear)
                                .border(Color.gray, width: 1)
                        }

                        // Controls
                        if horizontalSizeClass == .regular {
                            VStack(alignment: .center, spacing: 24) {
                                // Tool Buttons
                                ToolButtonView()
                                    .environmentObject(drawingVM)
                                    .layoutPriority(0)

                                // Color Palette
                                ColorPaletteView()
                                    .environmentObject(drawingVM)
                                    .padding(.horizontal, 20)

                                // Brush Size Slider
                                VStack(alignment: .leading) {
                                    BrushSizeView(cvm: drawingVM)
                                }
                                .layoutPriority(1)  // Force this to not be squeezed
                                .padding(.horizontal)

                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 12)
                        } else {
                            ToolButtonView().environmentObject(drawingVM)

                            ColorPaletteView()
                                .padding(.horizontal, 20)
                                .environmentObject(drawingVM)

                            BrushSizeView(cvm: drawingVM)
                                .padding(.horizontal, 20)

                        }

                        Button {
                            if drawingVM.drawing.strokes.isEmpty {
                                showingNoDrawingAlert = true
                            } else {
                                let uiImage = drawingVM.drawing.image(
                                    from: CGRect(
                                        x: 0,
                                        y: 0,
                                        width: canvasSize,
                                        height: canvasSize
                                    ),
                                    scale: UIScreen.main.scale
                                )
                                userDrawnImage = Image(uiImage: uiImage)
                                drawingFinished = true
                            }
                        } label: {
                            Text("Finish")
                                .font(.callout)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .padding(.horizontal, 42)
                                .padding(.vertical, 12)
                                .background(
                                    Color(red: 0.918, green: 0.878, blue: 0.855)
                                )
                                .cornerRadius(15)
                                .shadow(
                                    color: Color.black.opacity(0.15),
                                    radius: 3,
                                    x: 0,
                                    y: 3
                                )
                        }
                        .alert(isPresented: $showingNoDrawingAlert) {
                            Alert(
                                title: Text("No Drawing"),
                                message: Text(
                                    "Please draw something before finishing."
                                ),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                        .padding(.top)
                    }
                } else {
                    VStack {
                        Text("The Result")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.bottom, 20)

                        ZStack {
                            Image(currentImageKey)
                                .resizable()
                                .scaledToFit()
                                .frame(width: canvasSize, height: canvasSize)
                                .opacity(0.3)
                                .border(Color.gray, width: 1)

                            if let finalImage = userDrawnImage {
                                finalImage
                                    .resizable()
                                    .scaledToFit()
                                    .frame(
                                        width: canvasSize,
                                        height: canvasSize
                                    )
                                    .border(Color.blue, width: 1)
                            } else {
                                Text("No drawing captured.")
                            }
                        }
                        .padding(.bottom, 20)

                        Button("Play Again") {
                            drawingVM.clear()
                            userDrawnImage = nil
                            drawingFinished = false

                            let randomImage = imageNameMap.randomElement()
                            currentImageKey = randomImage?.key ?? "2"
                            currentImageName = randomImage?.value ?? "Apple"
                            drawingVM.strokeColor = .black
                            drawingVM.strokeWidth = 10.0
                            drawingVM.usePen()
                        }
                        .font(.callout)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.horizontal, 42)
                        .padding(.vertical, 12)
                        .background(
                            Color(red: 0.918, green: 0.878, blue: 0.855)
                        )
                        .cornerRadius(15)
                        .shadow(
                            color: Color.black.opacity(0.15),
                            radius: 3,
                            x: 0,
                            y: 3
                        )
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
}

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

    func updateUIViewController(
        _ uiViewController: UIViewController,
        context: Context
    ) {
        guard let canvasView = context.coordinator.canvasView else { return }
        canvasView.tool = viewModel.tool
        if canvasView.drawing != viewModel.drawing {
            canvasView.drawing = viewModel.drawing
        }
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        let viewModel: DrawingViewModel
        weak var canvasView: PKCanvasView?

        init(viewModel: DrawingViewModel) {
            self.viewModel = viewModel
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            viewModel.drawing = canvasView.drawing
        }
    }
}

// MARK: - Color Palette View
private struct ColorPaletteView: View {
    @EnvironmentObject var drawingVM: DrawingViewModel
    @StateObject var colorMixingVM = ColorMixingViewModel()

    private var colorPaletteHeader: some View {
        HStack {
            Text("Colors")
                .font(.headline)
                .foregroundColor(.primary)
            Spacer()
            HStack(spacing: 8) {
                Text("Current:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Circle()
                    .fill(drawingVM.strokeColor)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle().stroke(Color.black.opacity(0.3), lineWidth: 1)
                    )
            }
        }
    }

    private var colorScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(colorMixingVM.unlockedColors) { item in
                    colorCircle(for: item)
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
        }
    }

    private func colorCircle(for item: ColorItem) -> some View {
        let color = Color(hex: item.hex)
        let isSelected = drawingVM.strokeColor == color

        return Circle()
            .fill(color)
            .frame(width: isSelected ? 40 : 35, height: isSelected ? 40 : 35)
            .overlay(selectedColorOverlay(isSelected: isSelected))
            .overlay(colorCircleBorder(isSelected: isSelected))
            .scaleEffect(isSelected ? 1.1 : 1.0)
            .shadow(
                color: isSelected ? color.opacity(0.4) : .clear,
                radius: 8,
                x: 0,
                y: 4
            )
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    drawingVM.strokeColor = color
                    drawingVM.updateToolColorOrWidth()
                }
            }
            .animation(
                .spring(response: 0.3, dampingFraction: 0.6),
                value: isSelected
            )
    }

    private func selectedColorOverlay(isSelected: Bool) -> some View {
        Circle()
            .stroke(Color.white, lineWidth: 3)
            .opacity(isSelected ? 1 : 0)
    }

    private func colorCircleBorder(isSelected: Bool) -> some View {
        Circle()
            .stroke(Color.black.opacity(0.3), lineWidth: isSelected ? 2 : 1)
    }

    var body: some View {
        VStack {
            colorPaletteHeader
            colorScrollView
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - ToolButton View
private struct ToolButtonView: View {
    @EnvironmentObject var drawingVM: DrawingViewModel

    private func toolButton(
        icon: String,
        isSelected: Bool,
        isDisabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(
                    isDisabled ? .gray : (isSelected ? .white : .blue)
                )
                .frame(width: 44, height: 44)
                .background(isSelected ? .blue : Color(.systemGray5))
                .clipShape(Circle())
        }
        .disabled(isDisabled)
    }

    var body: some View {
        HStack {
            toolButton(
                icon: "pencil.tip",
                isSelected: drawingVM.currentTool == .pen,
                isDisabled: false,
                action: drawingVM.usePen
            )
            toolButton(
                icon: "eraser",
                isSelected: drawingVM.currentTool == .softEraser,
                isDisabled: false,
                action: drawingVM.useSoftEraser
            )
            toolButton(
                icon: "scissors",
                isSelected: drawingVM.currentTool == .strokeEraser,
                isDisabled: false,
                action: drawingVM.useStrokeEraser
            )
            toolButton(
                icon: "pencil",
                isSelected: drawingVM.currentTool == .pencil,
                isDisabled: !drawingVM.pencilEnabled,
                action: drawingVM.usePencil
            )
            .disabled(!drawingVM.pencilEnabled)
            toolButton(
                icon: "paintbrush.pointed",
                isSelected: drawingVM.currentTool == .marker,
                isDisabled: !drawingVM.markerEnabled,
                action: drawingVM.useMarker
            )
            .disabled(!drawingVM.markerEnabled)
            toolButton(
                icon: "highlighter",
                isSelected: drawingVM.currentTool == .crayon,
                isDisabled: !drawingVM.crayonEnabled,
                action: drawingVM.useCrayon
            )
            .disabled(!drawingVM.crayonEnabled)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
    }
}
private struct BrushSizeView: View {
    @ObservedObject var cvm: DrawingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            brushSizeHeader
            brushSizeSlider
        }
        .padding(16)
        .background(sectionBackground)
    }

    private var brushSizeHeader: some View {
        HStack {
            Text("Brush Size")
                .font(.headline)
                .foregroundColor(.primary)

            Spacer()

            brushSizeIndicator
        }
    }

    private var brushSizeIndicator: some View {
        HStack(spacing: 8) {
            Text("\(Int(cvm.strokeWidth))pt")
                .font(.caption)
                .foregroundColor(.secondary)
                .monospacedDigit()

            Circle()
                .fill(cvm.strokeColor)
                .frame(
                    width: min(cvm.strokeWidth * 1.5, 25),
                    height: min(cvm.strokeWidth * 1.5, 25)
                )
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.3), lineWidth: 0.5)
                )
        }
    }

    private var brushSizeSlider: some View {
        HStack(spacing: 16) {
            minSizeIndicator

            Slider(value: $cvm.strokeWidth, in: 1...20, step: 1) {
                Text("Brush Size")
            }
            .tint(cvm.strokeColor)
            .onChange(of: cvm.strokeWidth) { _ in
                cvm.updateToolColorOrWidth()
            }

            maxSizeIndicator
        }
    }

    private var minSizeIndicator: some View {
        Circle()
            .fill(Color.gray.opacity(0.4))
            .frame(width: 4, height: 4)
    }

    private var maxSizeIndicator: some View {
        Circle()
            .fill(Color.gray.opacity(0.4))
            .frame(width: 16, height: 16)
    }

    private var sectionBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
    }
}

// MARK: - Preview Provider

#Preview {
    TraceImageGameView()
        .previewDevice("iPad Pro (12.9-inch) (6th generation)")  // You can choose another iPad here
        .previewInterfaceOrientation(.landscapeLeft)
}
