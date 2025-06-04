import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userAuth: UserViewModel
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top){
                Circle().fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "A7328C"), Color(hex: "f03e3e"), Color(hex: "F9B351")]),
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    )
                ).frame(width: UIScreen.main.bounds.width * 1.75, height: 450)
                    .offset(y: -280)
                VStack {
                    
                    Spacer()
                        .frame(height: 40)
                    VStack(spacing: 20) {
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
                        .frame(width: 160, height: 160)  // Match the ZStack's intended size
                        
                        // User Name
                        Text(
                            userAuth.userModel.name.isEmpty
                            ? "Guest User" : userAuth.userModel.name
                        )
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.top, 10)
                        
                        VStack{
                            Text("Level \(userAuth.userModel.level)")
                            ProgressView(
                                value: (
                                    Double(userAuth.userModel.currXP)/Double(userAuth.userModel.maxXP)
                                )
                                
                            )
                            
                            
                        }
                        .padding(.horizontal)
                        
                        // "My Project" Button
                        Button(action: {
                            // Action for My Project
                            print("My Project button tapped!")
                        }) {
                            HStack {
                                Image(systemName: "folder.fill")
                                    .font(.title2)
                                Text("My Project")
                                    .font(.headline)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 30)
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(15)
                            .foregroundColor(.black)
                            
                            // "Memorize game" Button
                            
                        }
                        .padding(.horizontal, 24)
                        
                        Button(action: {
                            Task {
                                await userAuth.logout()
                            }
                        }) {
                            Text("Logout")
                                .font(.headline)
                                .foregroundColor(.red)
                        }
                        .padding(.top, 20)
                        
                        Spacer()  // Pushes content to the center/top
                    }
                    
                    .onAppear {
                        // Ensure user data is loaded when this view appears
                        // This is crucial if this view is presented directly after login
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
                        }
                    }
                }
            }
        }
    }
}



#Preview {
    ProfileView()
        .environmentObject(UserViewModel())  // Provide a UserViewModel for preview
}
