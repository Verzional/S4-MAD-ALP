import SwiftUI

struct UserView: View {
    @EnvironmentObject private var userAuth: UserViewModel

    @State private var isRegister = false
    @State private var showAlert = false
    @State private var isLogin = false
    @State private var errorMessage: String = ""

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
                            VStack(alignment: .leading, spacing: 4) {
                                TextField(
                                    "Full name",
                                    text: $userAuth.userModel.name
                                )
                                .textInputAutocapitalization(.words)
                                Divider().background(Color.gray)
                            }
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
                                await userAuth.register()
                                if userAuth.isRegister {
                                    withAnimation {
                                        isRegister = false
                                    }
                                } else {
                                    showAlert = userAuth.falseCredential
                                }
                            } else {
                                await userAuth.login()
                                if userAuth.user != nil {
                                    print(
                                        "✅ Login Success: \(userAuth.user?.uid ?? "")"
                                    )
                                } else {
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
            .alert("Login Failed", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Incorrect email or password.")
            }
        }
    }
}

#Preview {
    UserView()
        .environmentObject(UserViewModel())
}
