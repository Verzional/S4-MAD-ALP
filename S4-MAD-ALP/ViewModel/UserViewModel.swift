import Firebase
import FirebaseAuth
import FirebaseDatabase
import Foundation
import SwiftUI
import PencilKit

@MainActor
class UserViewModel: ObservableObject {
    @Published var user: User?
    @Published var userModel: UserModel
    @Published var userId: String?
    @Published var isLogin: Bool
    @Published var isRegister: Bool
    @Published var falseCredential: Bool
    @Published var authErrorMessage: String = ""
    @Published var registrationSuccess: Bool = false
    @Published var profileImage: Image?
    @Published var projects: [DrawingProject] = []

    private let db = Database.database().reference()
    private let defaults = UserDefaults.standard
    private let profileImageKey = "userProfileImage_"

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
            loadLocalProfileImage(userId: uid)

            print("✅ User profile loaded for user ID: \(uid), Name: \(self.userModel.name)")

        } else {
            print("⚠️ No user profile found for uid \(uid)")
        }
    }

    func register(imageData: Data?) async {
        do {
            let result = try await Auth.auth()
                .createUser(
                    withEmail: userModel.email,
                    password: userModel.password
                )

            let uid = result.user.uid
            let userData: [String: Any] = [
                "name": userModel.name,
                "email": userModel.email,
                "image": "", // We won't store image path in DB for local storage
            ]

            try await db.child("users").child(uid).setValue(userData)

            // Save image locally
            if let imageData = imageData {
                saveLocalProfileImage(userId: uid, imageData: imageData)
            }

            DispatchQueue.main.async {
                self.userModel.password = ""
                self.authErrorMessage = ""
                self.falseCredential = false
                self.isRegister = true
                self.registrationSuccess = true
                self.profileImage = nil // Clear temporary image
            }

            print("✅ Account successfully created for user: \(userModel.email) with UID: \(uid)")

        } catch {
            DispatchQueue.main.async {
                self.registrationSuccess = false
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

    private func saveLocalProfileImage(userId: String, imageData: Data) {
        let key = profileImageKey + userId
        let base64String = imageData.base64EncodedString()
        defaults.set(base64String, forKey: key)
        print("✅ Profile image saved locally for user ID: \(userId), Base64 URL: \(base64String.prefix(20))...") // Show first 20 chars
    }

    private func loadLocalProfileImage(userId: String) {
        let key = profileImageKey + userId
        if let base64String = defaults.string(forKey: key),
           let imageData = Data(base64Encoded: base64String),
           let uiImage = UIImage(data: imageData) {
            DispatchQueue.main.async {
                self.profileImage = Image(uiImage: uiImage)
                print("✅ Profile image loaded locally for user ID: \(userId), Base64 URL: \(base64String.prefix(20))...") // Show first 20 chars
            }
        } else {
            print("⚠️ No local profile image found for user ID: \(userId)")
        }
    }

    func login() async {
        do {
            let result = try await Auth.auth().signIn(
                withEmail: userModel.email,
                password: userModel.password
            )

            let uid = result.user.uid

            DispatchQueue.main.async {
                self.falseCredential = false
                self.authErrorMessage = ""
                self.isLogin = true
                self.loadLocalProfileImage(userId: uid)
            }

            print("✅ SignIn Success for user ID: \(uid), Email: \(userModel.email)")

            try await fetchUser(uid: uid)

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
            self.isLogin = false // Crucial: Set isLogin to false on logout
            self.falseCredential = false
            self.userModel = UserModel()
            self.profileImage = nil // Clear displayed image on logout

            print("✅ SignOut Success: User cleared.")

        } catch {
            self.falseCredential = true
            print("❌ SignOut Error: \(error.localizedDescription)")
        }
    }
    
    func gainXP(xp: Int) {
        self.userModel.currXP += xp
        if(self.userModel.currXP >= self.userModel.maxXP){
            self.userModel.level += 1
            self.userModel.currXP -= self.userModel.maxXP
            self.userModel.maxXP = Int(Double(self.userModel.maxXP) * 1.1)
        }
    }
    
    
    func addProject(name: String? = nil, drawing: PKDrawing) {
            let newProjectInMemory = DrawingProject(name: name, drawing: drawing)
            let success = LocalDrawingStorage.shared.saveDrawingData(newProjectInMemory.drawing, filename: newProjectInMemory.drawingDataFilename)

            if success {
                projects.append(newProjectInMemory)
                saveMetadataIndex()
                print("Project added and saved locally. Total projects: \(projects.count)")
            } else {
                print("Failed to save drawing data to disk for new project.")
            }
        }
        
        func deleteProject(_ projectToDelete: DrawingProject) {
            LocalDrawingStorage.shared.deleteDrawingData(filename: projectToDelete.drawingDataFilename)
            projects.removeAll { $0.id == projectToDelete.id }
            saveMetadataIndex()
            print("Project deleted. Remaining projects: \(projects.count)")
        }

        private func saveMetadataIndex() {
            let metadataArray = projects.map {
                DrawingProjectMetadata(id: $0.id,
                                       name: $0.name,
                                       creationDate: $0.creationDate,
                                       lastModifiedDate: $0.lastModifiedDate,
                                       drawingDataFilename: $0.drawingDataFilename)
            }
            LocalDrawingStorage.shared.saveProjectsMetadata(metadataArray)
        }

        func loadProjectsFromDisk() {
            let metadataArray = LocalDrawingStorage.shared.loadProjectsMetadata()
            var loadedProjects: [DrawingProject] = []

            for metadata in metadataArray {
                if let drawing = LocalDrawingStorage.shared.loadDrawingData(filename: metadata.drawingDataFilename) {
                    let project = DrawingProject(id: metadata.id,
                                                 name: metadata.name,
                                                 drawing: drawing,
                                                 creationDate: metadata.creationDate,
                                                 lastModifiedDate: metadata.lastModifiedDate,
                                                 drawingDataFilename: metadata.drawingDataFilename)
                    loadedProjects.append(project)
                } else {
                    print("Could not load drawing data for project ID: \(metadata.id)")
                }
            }
            self.projects = loadedProjects
            print("Loaded \(projects.count) projects from disk.")
        }
        
        func updateProjectDrawing(projectID: UUID, newDrawing: PKDrawing) {
            guard let index = projects.firstIndex(where: { $0.id == projectID }) else {
                print("Project with ID \(projectID) not found for update.")
                return
            }
            projects[index].drawing = newDrawing
            projects[index].lastModifiedDate = Date()
            
            let success = LocalDrawingStorage.shared.saveDrawingData(newDrawing, filename: projects[index].drawingDataFilename)
            
            if success {
                saveMetadataIndex()
                print("Project \(projectID) drawing updated and saved.")
            } else {
                print("Failed to save updated drawing data for project \(projectID).")
            }
        }
}
