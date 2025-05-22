struct ColorMixingView: View {
    @StateObject var viewModel = ColorInventoryViewModel()

    @State private var selected1: ColorItem?
    @State private var selected2: ColorItem?

    var body: some View {
        VStack(spacing: 20) {
            Text("Unlocked Colors")
                .font(.headline)

            ScrollView(.horizontal) {
                HStack {
                    ForEach(viewModel.unlockedColors) { color in
                        Circle()
                            .fill(Color(hex: color.hex))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Circle()
                                    .stroke(selected1 == color || selected2 == color ? Color.black : Color.clear, lineWidth: 3)
                            )
                            .onTapGesture {
                                if selected1 == nil {
                                    selected1 = color
                                } else if selected2 == nil && color != selected1 {
                                    selected2 = color
                                }
                            }
                    }
                }
            }

            Button("Mix Colors") {
                guard let color1 = selected1, let color2 = selected2 else { return }
                let newHex = mixColors(hex1: color1.hex, hex2: color2.hex)

                if !viewModel.isColorUnlocked(newHex) {
                    let newColor = ColorItem(id: UUID(), name: "Mixed", hex: newHex)
                    viewModel.addNewColor(newColor)
                }

                selected1 = nil
                selected2 = nil
            }
            .disabled(selected1 == nil || selected2 == nil)

            Spacer()
        }
        .padding()
    }
}
