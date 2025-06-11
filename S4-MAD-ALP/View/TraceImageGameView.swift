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
    
    @EnvironmentObject var uvm: UserViewModel
    
    @State private var showingColorPickerSheet = false
    
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
    
            let canvasSize = min(geometry.size.width, geometry.size.height)
            
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
                        
                        Spacer()
                        // Canvas + Trace Image
                        ZStack {
                            //ngambil imagenya
                            Image(currentImageKey)
                                .resizable()
                                .scaledToFit()
                                .opacity(0.3)
                                .frame(width: canvasSize*0.85, height: canvasSize)
                            
                            //ngambil canvas wrappernya
                            CanvasViewWrapper()
                                .environmentObject(cvm)
                                .environmentObject(uvm)
                                .frame(width: canvasSize*0.85, height: canvasSize)
                                .aspectRatio(1, contentMode: .fit)
                                .background(Color.clear)
                                .layoutPriority(1)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .border(Color.gray, width: 1)
                                
                            
                        }
                        
                        
                        // Controls, ini handle yang orientationnya vertical atau horizontal
                        let isLandscape = horizontalSizeClass == .regular
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
                        Button {
                            if cvm.drawing.strokes.isEmpty {
                                showingNoDrawingAlert = true
                            } else {
                                //ini manggil dVM di drawing (PKDrawing) sebagai object, terus diubah jadi image (bawaan swiftui dalam PKDrawing UIImage) lalu ditampilin secara statis
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
                                drawingFinished = true
                            }
                        } label: {
                            Text("Finish")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .font(.headline)
                                .padding(.top, 10)
                                .padding(.horizontal)
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
                                    .frame(width: canvasSize*0.85, height: canvasSize)
                                    .opacity(0.3)
                                    .border(Color.gray, width: 1)
                                
                                //userDrawnimage ini nyimpen si uiimage yang udah dibuat sebelumnya (pada saat click finish) dalam var finalImage biar bisa ditampilin, resizeable sama scaledtofitnya ini biar bisa menyesuaikan besarnya.
                                if let finalImage = userDrawnImage {
                                    finalImage
                                        .resizable()
                                        .scaledToFit()
                                        .frame(
                                            width: canvasSize*0.85,
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
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .font(.headline)
                            .padding(.top, 10)
                            .padding(.horizontal)
                        }
                        //kalau ini gk ada, nanti gk ditengah, mencong kanan kiri
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                
            }
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
    TraceImageGameView()
        .environmentObject(DrawingViewModel())
        .environmentObject(UserViewModel())
}
