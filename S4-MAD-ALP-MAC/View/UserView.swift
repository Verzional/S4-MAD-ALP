import SwiftUI
import PhotosUI

struct UserView: View {
    @EnvironmentObject private var userAuth: UserViewModel
    @State private var isRegister = false
    @State private var showAlert = false
    @State private var errorMessage: String = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var tempProfileImage: Image? // Temporary image during selection
    @State private var profileImageData: Data?

    var body: some View {
        NavigationStack {
            ZStack {
                
                VStack {
                    Spacer().frame(height: 40)

                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(
                            isRegister
                                ? "Create\nnew account" : "Welcome\nback!"
                        )
                        .font(.system(size: 52, weight: .bold))
                        .foregroundColor(.white)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.orange)
                            .frame(width: 30, height: 4)
                    }
                    .padding(.horizontal, 36)
                    .frame(maxWidth: 600, alignment: .leading)


                    ZStack(){
                        Rectangle()
                            .foregroundColor(.clear)
                            .background(Color(red: 0.85, green: 0.85, blue: 0.85).opacity(0.47))
                            .cornerRadius(40)
                            .blur(radius: 3.2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 40)
                                    .inset(by: 0.5)
                                    .stroke(Color(red: 0.82, green: 0.82, blue: 0.82), lineWidth: 1)
                            )
                        VStack{
                            VStack(spacing: 20) {
                                if isRegister {
                                    // Profile Image Picker
                                    PhotosPicker(
                                        selection: $selectedItem,
                                        matching: .images,
                                        photoLibrary: .shared()
                                    ) {
                                        if let image = tempProfileImage {
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 80, height: 80)
                                                .clipShape(Circle())
                                        } else if let loadedImage = userAuth.profileImage {
                                            loadedImage
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 80, height: 80)
                                                .clipShape(Circle())
                                        } else {
                                            Circle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(width: 80, height: 80)
                                                .overlay(
                                                    Image(systemName: "photo.fill")
                                                        .font(.title)
                                                        .foregroundColor(.gray)
                                                )
                                        }
                                    }
//                                    .onChange(of: selectedItem) { newItem in
//                                        Task {
//                                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
//                                                profileImageData = data
//                                                if let nsImage = NSImage(data: data) {
//                                                    tempProfileImage = Image(uiImage: uiImage)
//                                                }
//                                            }
//                                            selectedItem = nil
//                                        }
//                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Full Name")
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color.white)
                                        TextField(
                                            "Full name",
                                            text: $userAuth.userModel.name
                                        )
                                        
                                        Divider().background(Color.gray)
                                    }
                                } else {
                                    // No image displayed on the login screen
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Email")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color.white)
                                    TextField(
                                        "Email address",
                                        text: $userAuth.userModel.email
                                    )
                                    .foregroundColor(.white)
                                    Rectangle()
                                        .frame(height: 1)
                                        .foregroundColor(.white)
                                }.padding(.vertical)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Password")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color.white)
                                    SecureField(
                                        isRegister ? "Create password" : "Password",
                                        text: $userAuth.userModel.password
                                    )
                                    .foregroundColor(.white)
                                    Rectangle()
                                        .frame(height: 1)
                                        .foregroundColor(.white)
                                }.padding(.vertical)
                            }
                            
                            .padding(.horizontal, 24)
                            .padding(.top, 12)
                            
                            
            
                            
    
                            Button {
                                Task {
                                    if isRegister {
                                        await userAuth.register(imageData: profileImageData)
                                        if userAuth.registrationSuccess {
                                            withAnimation {
                                                isRegister = false // This line redirects to login state
                                                tempProfileImage = nil
                                                profileImageData = nil
                                            }
                                        } else {
                                            showAlert = userAuth.falseCredential
                                        }
                                    } else {
                                        await userAuth.login()
                                        // The userAuth.isLogin property will be set to true inside userAuth.login()
                                        // The parent view observing userAuth.isLogin will handle navigation
                                        if userAuth.user == nil { // Only show alert if login failed
                                            showAlert = true
                                        }
                                    }
                                }
                            } label: {
                                Text(isRegister ? "Sign Up!" : "Sign In!")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                    .font(.headline)
                            }
                            .padding(.horizontal, 25)
                            .padding(.top, 40)
                            
                            // Toggle login/register
                            Button {
                                withAnimation {
                                    isRegister.toggle()
                                }
                            } label: {
                                Text(
                                    isRegister
                                    ? "Already have an account? Sign In"
                                    : "Don't have an account? Sign Up"
                                )
                                .font(.footnote)
                            }
                            .padding(.top, 8)
                        }.padding(.vertical, 32)
                    }.padding()
                        .frame(maxWidth:600)
                            Spacer(minLength: 32)
                        
                }.frame(maxWidth: .infinity)
                
            }
            .frame(minHeight: 600)
            .background(
                LinearGradient(
                stops: [
                Gradient.Stop(color: Color(red: 0.98, green: 0.7, blue: 0.32), location: 0.00),
                Gradient.Stop(color: Color(red: 1, green: 0.32, blue: 0.31), location: 0.31),
                Gradient.Stop(color: Color(red: 0.71, green: 0.34, blue: 0.82), location: 0.77),
                Gradient.Stop(color: Color(red: 0.13, green: 0.49, blue: 0.91), location: 1.00),
                ],
                startPoint: UnitPoint(x: 0.91, y: 0),
                endPoint: UnitPoint(x: 0.09, y: 1)
                )
            )
            .alert(userAuth.authErrorMessage, isPresented: $userAuth.falseCredential) {
                Button("OK", role: .cancel) {}
            }
            // Removed .navigationDestination here, it moves to the root view
        }
    }
}

#Preview {
    UserView()
        .environmentObject(UserViewModel())
}
