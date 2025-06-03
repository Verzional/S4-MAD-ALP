import SwiftUI
import PencilKit

struct DrawingView: View {
    @EnvironmentObject var cvm: DrawingViewModel
    @EnvironmentObject var cmvm: ColorMixingViewModel
    @EnvironmentObject var userData: UserViewModel
    
    @State private var showingColorPickerSheet = false

    var body: some View {
        VStack(spacing: 15) {
            CanvasViewWrapper()
                .environmentObject(cvm)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 3)
                .layoutPriority(1)

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
            }
            .padding(.horizontal)
            .frame(height: 60)
        }
        .padding()
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .sheet(isPresented: $showingColorPickerSheet) {
            ColorPickerSheetView(onColorSelect: { selectedColorItem in
                cvm.strokeColor = Color(hex: selectedColorItem.hex)
                cvm.updateToolColorOrWidth()
                showingColorPickerSheet = false
            })
            .environmentObject(cmvm)
        }
        .onAppear {
            cvm.levelCheck(level: userData.userModel.level)
        }
    }

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
                viewModel.drawing = canvasView.drawing
            }
        }
    }
}

extension Color {
    var isDark: Bool {
        var r, g, b, a: CGFloat
        (r, g, b, a) = (0, 0, 0, 0)
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
        return luminance < 0.5
    }
}


#Preview {
    let drawingVM = DrawingViewModel()
    let colorMixingVM = ColorMixingViewModel()
    let userVM = UserViewModel()

    colorMixingVM.unlockedColors = [
        ColorItem(id: UUID(), name: "Preview Red", hex: "#FF0000"),
        ColorItem(id: UUID(), name: "Preview Green", hex: "#00FF00"),
        ColorItem(id: UUID(), name: "Preview Blue", hex: "#0000FF")
    ]
    userVM.userModel.level = 1
    drawingVM.levelCheck(level: userVM.userModel.level)


    return DrawingView()
        .environmentObject(drawingVM)
        .environmentObject(colorMixingVM)
        .environmentObject(userVM)
}
