import SwiftUI
import PencilKit

struct DrawingView: View {
    @EnvironmentObject var cvm : DrawingViewModel
    @EnvironmentObject var cmvm: ColorMixingViewModel
    @EnvironmentObject var userData: UserViewModel
    @State private var selectedTab: ToolTab = .tools // New state to manage selected tab

        enum ToolTab: String, CaseIterable, Identifiable {
            case tools = "Tools"
            case colors = "Colors"
            case size = "Size"

            var id: String { self.rawValue }
            var systemImage: String {
                switch self {
                case .tools: return "pencil.and.outline"
                case .colors: return "paintpalette.fill"
                case .size: return "paintbrush.pointed.fill"
                }
            }
        }
    

    var body: some View {
            
            VStack(spacing: 20) {
                // MARK: - Canvas View Wrapper
                           CanvasViewWrapper()
                               .environmentObject(cvm)
                               .background(Color.white)
                               .frame(minHeight: 300, maxHeight: 600) // Ensure canvas has a visible height range
                               .clipShape(RoundedRectangle(cornerRadius: 12))

                           // MARK: - Custom Tab Buttons
                           HStack {
                               ForEach(ToolTab.allCases) { tab in
                                   Button(action: {
                                       withAnimation {
                                           selectedTab = tab
                                       }
                                   }) {
                                       Label(tab.rawValue, systemImage: tab.systemImage)
                                           .font(.headline)
                                           .padding(.vertical, 8)
                                           .padding(.horizontal, 15)
                                           .background(selectedTab == tab ? Color.accentColor : Color(.systemGray5))
                                           .foregroundColor(selectedTab == tab ? .white : .primary)
                                           .cornerRadius(10)
                                   }
                               }
                           }
                           .padding(.horizontal, 16) // Padding for the button row

                           // MARK: - Conditionally Displayed Tool Sections
                           Group { // Use Group to conditionally show views
                               if selectedTab == .tools {
                                   toolPickerSection
                               } else if selectedTab == .colors {
                                   colorPaletteSection
                               } else if selectedTab == .size {
                                   brushSizeSection
                               }
                           }
                           // Optional: Give the content area a fixed height if you want it to scroll
                           // independently or maintain a consistent layout.
                            .frame(height: 100) // Adjust height as needed for your sections

                       }
                       .padding(16) // Padding for the content inside the VStack
                       .background(Color(.systemGroupedBackground)) // Background for the entire view
                       .onAppear{
                           cvm.levelCheck(level: userData.userModel.level)
                       }
    

    }
    

    func toolButton(icon: String, selected: Bool, disabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(disabled ? .gray : (selected ? .white : .blue))
                .frame(width: 44, height: 44)
                .background(selected ? .blue : Color(.systemGray5))
                .clipShape(Circle())
        }
        .disabled(disabled)
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
    
    private var toolPickerSection: some View {
        HStack(spacing: 12) {
                toolButton(icon: "pencil.tip", selected: cvm.currentTool == .pen, disabled: false, action: cvm.usePen)
            toolButton(icon: "eraser", selected: cvm.currentTool == .softEraser, disabled: false, action: cvm.useSoftEraser)
                toolButton(icon: "scissors", selected: cvm.currentTool == .strokeEraser, disabled: false,action: cvm.useStrokeEraser)
            toolButton(icon: "pencil", selected: cvm.currentTool == .pencil, disabled: !cvm.pencilEnabled,action: cvm.usePencil).disabled(!cvm.pencilEnabled)
            toolButton(icon: "paintbrush.pointed", selected: cvm.currentTool == .marker,disabled: !cvm.markerEnabled, action: cvm.useMarker).disabled(!cvm.markerEnabled)
                toolButton(icon: "highlighter", selected: cvm.currentTool == .crayon,disabled: !cvm.crayonEnabled, action: cvm.useCrayon).disabled(!cvm.crayonEnabled)
        }
        .padding(16)
        .background(sectionBackground)
    }
    
    private var colorPaletteSection: some View {
            VStack(alignment: .leading, spacing: 12) {
                colorPaletteHeader
                colorScrollView
            }
            .padding(16)
            .background(sectionBackground)
        }
        
        private var colorPaletteHeader: some View {
            HStack {
                Text("Colors")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                currentColorIndicator
            }
        }
        
        private var currentColorIndicator: some View {
            HStack(spacing: 8) {
                Text("Current:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Circle()
                    .fill(cvm.strokeColor)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .stroke(Color.black.opacity(0.3), lineWidth: 1)
                    )
            }
        }
        
        private var colorScrollView: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(cmvm.unlockedColors) { item in
                        colorCircle(for: item)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 4)
            }
        }
        
        private func colorCircle(for item: ColorItem) -> some View {
            let color = Color(hex: item.hex)
            let isSelected = cvm.strokeColor == color
            
            return Circle()
                .fill(color)
                .frame(width: isSelected ? 40 : 35, height: isSelected ? 40 : 35)
                .overlay(selectedColorOverlay(isSelected: isSelected))
                .overlay(colorCircleBorder(isSelected: isSelected))
                .scaleEffect(isSelected ? 1.1 : 1.0)
                .shadow(color: isSelected ? color.opacity(0.4) : Color.clear, radius: 8, x: 0, y: 4)
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        cvm.strokeColor = color
                        cvm.updateToolColorOrWidth()
                    }
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
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
        
        // MARK: - Brush Size Section
        private var brushSizeSection: some View {
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

#Preview {
    DrawingView()
        .environmentObject(DrawingViewModel())
        .environmentObject(ColorMixingViewModel())
        .environmentObject(UserViewModel())
}
