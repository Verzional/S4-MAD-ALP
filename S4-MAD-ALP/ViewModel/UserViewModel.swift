//
//  UserViewModel.swift
//  S4-MAD-ALP
//
//  Created by Gabriela Sihutomo on 22/05/25.
//

import Firebase
import FirebaseAuth
import FirebaseDatabase
import Foundation

@MainActor
class UserViewModel: ObservableObject {
    @Published var user: User?
    @Published var userModel: UserModel
    @Published var userId: String?
    @Published var isLogin: Bool
    @Published var isRegister: Bool
    @Published var falseCredential: Bool
    @Published var authErrorMessage: String = ""


    private let db = Database.database().reference()

    init() {
        self.user = nil
        self.isLogin = false
        self.isRegister = false
        self.falseCredential = false
        self.userModel = UserModel()
    }

    func fetchUser(uid: String) async throws {
        let snapshot = try await db.child("users").child(uid).getData()

        if let value = snapshot.value as? [String: Any] {
            self.userModel.name = value["name"] as? String ?? ""
            self.userModel.email = value["email"] as? String ?? ""

            print("✅ User profile loaded: \(self.userModel.name)")

        } else {
            print("⚠️ No user profile found for uid \(uid)")
        }
    }

    func register() async {
        do {
            let result = try await Auth.auth()
                .createUser(
                    withEmail: userModel.email,
                    password: userModel.password
                )

            let uid = result.user.uid
            let userData = [
                "name": userModel.name,
                "email": userModel.email,
            ]

            try await db.child("users").child(uid).setValue(userData)

            DispatchQueue.main.async {
                self.userModel.password = ""
                self.authErrorMessage = "" // reset error
                self.falseCredential = false // reset alert flag
                self.isRegister = true // untuk kembali ke login view
            }

            print("✅ Account successfully created for user: \(userModel.email) with UID: \(uid)")

        } catch {
            DispatchQueue.main.async {
                if let errorCode = AuthErrorCode(rawValue: (error as NSError).code) {
                    switch errorCode.code {
                    case .emailAlreadyInUse:
                        self.authErrorMessage = "This email is already registered."
                    case .invalidEmail:
                        self.authErrorMessage = "Please enter a valid email address."
                    case .weakPassword:
                        self.authErrorMessage = "Password must be at least 6 characters."
                    default:
                        self.authErrorMessage = "Registration failed: \(error.localizedDescription)"
                    }
                } else {
                    self.authErrorMessage = "Unexpected error occurred."
                }
                self.falseCredential = true
            }
        }
    }

    func login() async {
        do {
            let result = try await Auth.auth().signIn(
                withEmail: userModel.email,
                password: userModel.password
            )

            DispatchQueue.main.async {
                self.falseCredential = false
                self.authErrorMessage = "" // clear old error
            }

            print("✅ SignIn Success: User ID = \(result.user.uid)")

            try await fetchUser(uid: result.user.uid)

        } catch {
            DispatchQueue.main.async {
                if let errorCode = AuthErrorCode(rawValue: (error as NSError).code) {
                    switch errorCode.code {
                    case .userNotFound:
                        self.authErrorMessage = "Account not found. Please register first."
                    case .wrongPassword:
                        self.authErrorMessage = "Incorrect password. Please try again."
                    case .invalidEmail:
                        self.authErrorMessage = "Invalid email format."
                    default:
                        self.authErrorMessage = "Login failed: \(error.localizedDescription)"
                    }
                } else {
                    self.authErrorMessage = "Unexpected error occurred."
                }

                self.falseCredential = true
            }
        }
    }


    func logout() async {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.isLogin = false
            self.falseCredential = false

            print("✅ SignOut Success: User cleared.")

        } catch {
            self.falseCredential = true
            print("❌ SignOut Error: \(error.localizedDescription)")
        }
    }
}
