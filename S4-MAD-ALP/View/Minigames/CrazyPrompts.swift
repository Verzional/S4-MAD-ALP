import SwiftUI
import PencilKit

struct CrazyPrompts: View {
    @EnvironmentObject var cvm : DrawingViewModel
    @EnvironmentObject var cmvm: ColorMixingViewModel
    @EnvironmentObject var userData: UserViewModel
    @EnvironmentObject var tvm: ThemeDrawingViewModel
    
    var body: some View {

        VStack(spacing: 20) {
            Text(tvm.theme)
                .font(.title3)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            DrawingView()
                .environmentObject(cvm)
                .environmentObject(cmvm)
                .environmentObject(userData)
            

        }
        .toolbar(.hidden, for: .tabBar)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear(){
            cvm.clear()
        }


    }
    

 
}

#Preview {
    CrazyPrompts()
        .environmentObject(DrawingViewModel())
        .environmentObject(ColorMixingViewModel())
        .environmentObject(UserViewModel())
        .environmentObject(ThemeDrawingViewModel())
}
