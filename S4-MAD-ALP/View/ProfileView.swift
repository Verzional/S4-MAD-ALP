import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userAuth: UserViewModel
    @State var toolCount: Int = 3
    @State var minigames: Int = 2
    
    let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 10)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top){
                GeometryReader{ geometry in
                    
                    Circle().fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "A7328C"), Color(hex: "f03e3e"), Color(hex: "F9B351")]),
                            startPoint: .bottomLeading,
                            endPoint: .topTrailing
                        )
                    )
                    .frame(width: geometry.size.width * 2, height: geometry.size.height * 0.65)
                    .offset(x: -(geometry.size.width * 0.5), y: -geometry.size.height * 0.25)
                    .ignoresSafeArea()
                }
                
                VStack {
                    
                    Spacer()
                        .frame(height: 40)
                    VStack() {
                        ZStack(alignment: .bottom) {
                            GeometryReader { geometry in
                                Circle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(
                                        width: geometry.size.width * 1.1,
                                        height: geometry.size.height * 0.6
                                    )
                                    .offset(y: geometry.size.height * 0.4)
                            }
                            .frame(width: 160, height: 160)
                            
                            if let profileImage = userAuth.profileImage {
                                profileImage
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 150)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle().stroke(
                                            Color.gray.opacity(0.2),
                                            lineWidth: 2
                                        )
                                    )
                            } else {
                                // Placeholder if no image is loaded
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 200, height: 200)
                                    .overlay(
                                        Image(systemName: "person.circle.fill")
                                            .font(.system(size:180))
                                            .foregroundColor(.white)
                                    )
                            }
                        }
                        
                        
                        // User Name
                        Text(
                            userAuth.userModel.name.isEmpty
                            ? "Guest User" : userAuth.userModel.name
                        )
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 10)
                        
                        userLevel.padding(.top, 20)
                        
                        userInfo.padding(.top, 20)
                        
                        
                        Button(action: {
                            Task {
                                await userAuth.logout()
                            }
                        }) {
                            Text("Logout")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "A7328C"), Color(hex: "f03e3e")]),
                                    startPoint: .bottomLeading,
                                    endPoint: .topTrailing
                                ))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .font(.headline)
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 36)
                        
                        Spacer()
                    }
                    
                    .onAppear {
                       
                        if let uid = userAuth.user?.uid {
                            Task {
                                do {
                                    try await userAuth.fetchUser(uid: uid)
                                } catch {
                                    print(
                                        "Error fetching user data in ProfileAccountView: \(error.localizedDescription)"
                                    )
                                }
                            }
                            
                            if(userAuth.userModel.level>=2){
                                toolCount = 4
                            }
                            if(userAuth.userModel.level>=4){
                                toolCount = 5
                            }
                            if(userAuth.userModel.level>=6){
                                toolCount = 6
                            }
                            if (userAuth.userModel.level>=8){
                                toolCount = 6
                                minigames = 3
                            }
                            if (userAuth.userModel.level>=10){
                                minigames = 4
                            }
                        }
                        
                        
                    }
                }
            }
        }
    }
    
    private var userInfo: some View{
        LazyVGrid(columns: columns, spacing: 20) {
            
            
            Button(action: {
                print("Drawings button tapped!")
            }) {
                VStack(spacing: 8) {
                    Image(systemName: "photo.fill")
                        .font(.title2)
                    Text("\(userAuth.projects.count) Drawings")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(15)
                .foregroundColor(.black)
            }
            
            
            Button(action: {
                print("Colors button tapped!")
            }) {
                VStack(spacing: 8) {
                    Image(systemName: "paintpalette.fill")
                        .font(.title2)
                    Text("\(userAuth.unlockedColors.count) Colors")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(15)
                .foregroundColor(.black)
            }
            
            
            Button(action: {
                print("Tools button tapped!")
            }) {
                VStack(spacing: 8) {
                    Image(systemName: "paintbrush.fill")
                        .font(.title2)
                    Text("\(toolCount) Tools")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(15)
                .foregroundColor(.black)
            }
            
  
            Button(action: {
                print("My Project button tapped!")
            }) {
                VStack(spacing: 8) {
                    Image(systemName: "gamecontroller.fill")
                        .font(.title2)
                    Text("\(minigames) Minigames")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(15)
                .foregroundColor(.black)
            }
        }
        .padding(.horizontal, 36)
    }
    
    private var userLevel: some View{
        VStack() {
            HStack {
                
                Text("Level \(userAuth.userModel.level)")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Text("Next Level: \(userAuth.userModel.level + 1)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
            }
            
            ZStack(alignment: .leading){
                Rectangle()
                    .frame(width: .infinity, height: 22)
                    .foregroundColor(.gray.opacity(0.25))
                    .cornerRadius(12)
                Rectangle()
                    .frame(width: CGFloat(Double(userAuth.userModel.currXP) / Double(userAuth.userModel.maxXP) * 120), height: 8)
                    .foregroundColor(Color.blue)
                    .cornerRadius(12)
            }
            
        }.padding(.horizontal, 36)
    }
}


#Preview {
    ProfileView()
        .environmentObject(UserViewModel())
}
