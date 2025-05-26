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
                    Spacer(minLength: 40)

                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(
                            isRegister
                                ? "Create\nnew account" : "Welcome\nback!"
                        )
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.black)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.orange)
                            .frame(width: 30, height: 4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 24)

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
                            .onChange(of: selectedItem) { newItem in
                                Task {
                                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                        profileImageData = data
                                        if let uiImage = UIImage(data: data) {
                                            tempProfileImage = Image(uiImage: uiImage)
                                        }
                                    }
                                    selectedItem = nil
                                }
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                TextField(
                                    "Full name",
                                    text: $userAuth.userModel.name
                                )
                                .textInputAutocapitalization(.words)
                                Divider().background(Color.gray)
                            }
                        } else {
                            // No image displayed on the login screen
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            TextField(
                                "Email address",
                                text: $userAuth.userModel.email
                            )
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            Divider().background(Color.gray)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            SecureField(
                                isRegister ? "Create password" : "Password",
                                text: $userAuth.userModel.password
                            )
                            Divider().background(Color.gray)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)

                    Spacer()

                    // Action Button
                    Button {
                        Task {
                            if isRegister {
                                await userAuth.register(imageData: profileImageData)
                                if userAuth.registrationSuccess {
                                    withAnimation {
                                        isRegister = false
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
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .font(.headline)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)

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

                    Spacer(minLength: 32)
                }
            }
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
