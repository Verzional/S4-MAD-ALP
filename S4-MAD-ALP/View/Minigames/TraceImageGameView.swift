import PencilKit
import SwiftUI

struct TraceImageGameView: View {
    //agar layout menjadi responsif,
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    //buat nyimper gambaran user,trus null able krna awalnya kan kosongan
    @State private var userDrawnImage: Image?
    
    // dua ini pokoknya untuk load gambar dari asset,
    //ini ambil the real name of the image at asset from imagenamemapping
    @State private var currentImageKey: String
    
    //ini ambil the 'change' name of the image at asset from imagenamemapping
    @State private var currentImageName: String
    
    // Mengontrol apakah alert akan ditampilkan ketika pengguna mencoba
    // menyelesaikan tracing tapi belum menggambar apa-apa.
    @State private var showingNoDrawingAlert = false
    
    //bool ini menunjukkan kalau user masih menggambar atau sudah tidak menggambar
    @State private var drawingFinished = false
    
    //panggil logic dari drawing viemmodel, objek ini hidup selama view hidup dan akan otomatis update tampilan saat ada perubahan.
    @StateObject var cvm = DrawingViewModel()

    //ini buat ngambil si gambar yang ada di ImageNameMapping (imageNameMap)
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
        
        // geometryReader ini untuk responsive besar layarnya. Ukuran canvasSize
        // akan lebih besar di landscape (.regular) dan sedikit lebih kecil di portrait (.compact)
        GeometryReader { geometry in
            let maxCanvasSize = min(geometry.size.width, geometry.size.height)
            let canvasSize =
                maxCanvasSize * (horizontalSizeClass == .regular ? 0.85 : 0.9)

            ZStack {
                //ini pas mau mulai drawing, jadi kalau drawng blm finish (click button), bkalan ada di view yang nampilin z-stacknya biar bisa menggambar
                if !drawingFinished {
                    VStack {
                        // Header
                        HStack {
                            // ngambil name si currImage
                            Text("Draw \(currentImageName)")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.horizontal, 20)
                        }
                        .padding(.horizontal)

                        // Canvas + Trace Image
                        ZStack {
                            //ngambil imagenya
                            Image(currentImageKey)
                                .resizable()
                                .scaledToFit()
                                .opacity(0.3)
                                .frame(width: canvasSize, height: canvasSize)

                            //ngambil canvas wrappernya
                            CanvasViewWrapper()
                                .environmentObject(cvm)
                                .frame(width: canvasSize, height: canvasSize)
                                .aspectRatio(1, contentMode: .fit)
                                .background(Color.clear)
                                .border(Color.gray, width: 1)
                        }

                        // Controls, ini handle yang orientationnya vertical atau horizontal
                        let isLandscape = horizontalSizeClass == .regular

                        //spacingnya ini untuk jarak antar viewnya
                        VStack(alignment: .center, spacing: isLandscape ? 24 : 12) {
                            ToolButtonView()
                                .environmentObject(cvm)

                            ColorPaletteView()
                                .environmentObject(cvm)
                                .padding(.horizontal, 20)

                            VStack(alignment: .leading) {
                                BrushSizeView(cvm: cvm)
                            }
                            .layoutPriority(1)
                            .padding(.horizontal)
                        }


                        Button {
                            if cvm.drawing.strokes.isEmpty {
                                showingNoDrawingAlert = true
                            } else {
                                //ini manggil dVM di drawing (PKDrawing) sebagai object, terus diubah jadi image (bawaan swiftui dalam PKDrawing UIImage) lalu ditampilin secara statis
                                let uiImage = cvm.drawing.image(
                                    from: CGRect(
                                        x: 0,
                                        y: 0,
                                        width: canvasSize,
                                        height: canvasSize
                                    ),
                                    scale: UIScreen.main.scale
                                )
                                // disini nanti Image dari PKDrawing itu diubah menjadi komponen SwiftUI
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
                            //nampilin imagenya
                            Image(currentImageKey)
                                .resizable()
                                .scaledToFit()
                                .frame(width: canvasSize, height: canvasSize)
                                .opacity(0.3)
                                .border(Color.gray, width: 1)

                            //userDrawnimage ini nyimpen si uiimage yang udah dibuat sebelumnya (pada saat click finish) dalam var finalImage biar bisa ditampilin, resizeable sama scaledtofitnya ini biar bisa menyesuaikan besarnya.
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

                        //untuk main ulang, nanti gambar dirandom lagi
                        Button("Play Again") {
                            //canvasnya diclean
                            cvm.clear()
                            userDrawnImage = nil
                            drawingFinished = false

                            //dirandom
                            let randomImage = imageNameMap.randomElement()
                            currentImageKey = randomImage?.key ?? "2"
                            currentImageName = randomImage?.value ?? "Apple"
                            
                            //dibuat default colornya di black
                            cvm.strokeColor = .black
                            
                            //tebal brushnya di 10
                            cvm.strokeWidth = 10.0
                            
                            //pake pen
                            cvm.usePen()
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
                    //kalau ini gk ada, nanti gk ditengah, mencong kanan kiri
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            //Saat keyboard muncul (misalnya karena ada TextField), tampilan tidak akan naik atau bergeser ke atas.
            .ignoresSafeArea(.keyboard, edges: .bottom)
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

// the color palette
private struct ColorPaletteView: View {
    @EnvironmentObject var cvm: DrawingViewModel
    @ObservedObject var colorMixingVM = ColorMixingViewModel()

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
                    .fill(cvm.strokeColor)
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

    //manggil model colornya
    private func colorCircle(for item: ColorItem) -> some View {
        //abis tu warna yang dipilih disimpen dulu
        let color = Color(hex: item.hex)
        let isSelected = cvm.strokeColor == color

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
                    //nnti wrna yang dipilih baru dicocokin sama yang diviewmodel
                    cvm.strokeColor = color
                    //nnti diupdate ke colornya pake bawaan dari PencilKitnya
                    cvm.updateToolColorOrWidth()
                }
            }
            .animation(
                .spring(response: 0.3, dampingFraction: 0.6),
                value: isSelected
            )
        //setelah itu bakalan dilempar lagi ke CanvasWrappernya biar bisa diimplement
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

// tool button
private struct ToolButtonView: View {
    @EnvironmentObject var cvm: DrawingViewModel

    private func toolButton(
        icon: String,
        isSelected: Bool,
        isDisabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        //button ini buat tool toolnya
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
                //ngmbil dri viewmodel kalau mau dipake, trus actionnya artiny pake toolnya
                isSelected: cvm.currentTool == .pen,
                isDisabled: false,
                action: cvm.usePen
            )
            toolButton(
                icon: "eraser",
                isSelected: cvm.currentTool == .softEraser,
                isDisabled: false,
                action: cvm.useSoftEraser
            )
            toolButton(
                icon: "scissors",
                isSelected: cvm.currentTool == .strokeEraser,
                isDisabled: false,
                action: cvm.useStrokeEraser
            )
            toolButton(
                icon: "pencil",
                isSelected: cvm.currentTool == .pencil,
                isDisabled: !cvm.pencilEnabled,
                action: cvm.usePencil
            )
            .disabled(!cvm.pencilEnabled)
            toolButton(
                icon: "paintbrush.pointed",
                isSelected: cvm.currentTool == .marker,
                isDisabled: !cvm.markerEnabled,
                action: cvm.useMarker
            )
            .disabled(!cvm.markerEnabled)
            toolButton(
                icon: "highlighter",
                isSelected: cvm.currentTool == .crayon,
                isDisabled: !cvm.crayonEnabled,
                action: cvm.useCrayon
            )
            .disabled(!cvm.crayonEnabled)
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
    //cocok observed karena ada ysng butuh pemantauan lebih kyak lebar tipisnya brush
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

#Preview {
    TraceImageGameView()
        .previewDevice("iPad Pro (12.9-inch) (6th generation)")  // You can choose another iPad here
        .previewInterfaceOrientation(.landscapeLeft)
}
