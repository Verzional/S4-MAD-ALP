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
    @Published var userId: String? // This is the optional property that can be nil
    @Published var isLogin: Bool
    @Published var isRegister: Bool
    @Published var falseCredential: Bool
    @Published var authErrorMessage: String = ""
    @Published var registrationSuccess: Bool = false
    @Published var profileImage: Image?
    @Published var projects: [DrawingProject] = []
    @Published var unlockedColors: [ColorItem] = []
    
    private let db = Database.database().reference()
    private let defaults = UserDefaults.standard
    private let profileImageKey = "userProfileImage_"
    
    init() {
        self.user = nil
        self.isLogin = false
        self.isRegister = false
        self.falseCredential = false
        self.userModel = UserModel()
        loadInitialColors()
    }
    
    func testInternetConnection() {
        print("--- Starting Internet Test ---")
        guard let url = URL(string: "https://www.google.com") else {
            print("❌ Invalid URL for test.")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ TEST FAILED: The app cannot connect to the internet.")
                print("   Error details: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("✅ TEST SUCCESSFUL: The app can connect to the internet.")
            } else {
                print("❌ TEST FAILED: Received a non-200 response.")
            }
        }
        task.resume()
    }
    
    private func loadInitialColors() {
        unlockedColors = [
            ColorItem(id: UUID(), name: "White", hex: "#FFFFFF"),
            ColorItem(id: UUID(), name: "Black", hex: "#000000"),
            ColorItem(id: UUID(), name: "Red", hex: "#FF0000"),
            ColorItem(id: UUID(), name: "Green", hex: "#00FF00"),
            ColorItem(id: UUID(), name: "Blue", hex: "#0000FF"),
            ColorItem(id: UUID(), name: "Yellow", hex: "#FFFF00"),
            ColorItem(id: UUID(), name: "Magenta", hex: "#FF00FF"),
            ColorItem(id: UUID(), name: "Cyan", hex: "#00FFFF")
        ]
    }
    
    func fetchUser(uid: String) async throws {
        let snapshot = try await db.child("users").child(uid).getData()
        
        if let value = snapshot.value as? [String: Any] {
            self.userModel.name = value["name"] as? String ?? ""
            self.userModel.email = value["email"] as? String ?? ""
            self.userModel.currXP = value["currXP"] as? Int ?? 0
            self.userModel.maxXP = value["maxXP"] as? Int ?? 100
            self.userModel.level = value["level"] as? Int ?? 0
            loadLocalProfileImage(userId: uid)
            await loadColorsFromFirebase()
            
            print("✅ User profile loaded for user ID: \(uid), Name: \(self.userModel.name)")
            
        } else {
            print("⚠️ No user profile found for uid \(uid)")
        }
    }
    
    func saveUserToFirebase() async {
        guard let uid = user?.uid else {
            print("Error: User not logged in. Cannot save user to Firebase.")
            return
        }
        
        let xpData: [String: Any] = [
            "level": self.userModel.level,
            "currXP": self.userModel.currXP,
            "maxXP": self.userModel.maxXP,
        ]
        
        do {
                try await db.child("users").child(uid).updateChildValues(xpData)
                print("✅ User XP and level data saved to Firebase.")
            } catch {
                print("❌ Error saving user XP data to Firebase: \(error.localizedDescription)")
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
                "image": "",
                "level": 0,
                "currXP": 0,
                "maxXP": 100
            ]
            
            try await db.child("users").child(uid).setValue(userData)
            
            
            if let imageData = imageData {
                saveLocalProfileImage(userId: uid, imageData: imageData)
            }
            
            self.user = result.user
            self.userId = uid // Make sure userId is set here after registration
            loadInitialColors()
            await saveColorsToFirebase()
            
            DispatchQueue.main.async {
                self.userModel.password = ""
                self.authErrorMessage = ""
                self.falseCredential = false
                self.registrationSuccess = true
                self.profileImage = nil
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
        print("✅ Profile image saved locally for user ID: \(userId), Base64 URL: \(base64String.prefix(20))...")
    }
    
    private func loadLocalProfileImage(userId: String) {
        let key = profileImageKey + userId
        if let base64String = defaults.string(forKey: key),
           let imageData = Data(base64Encoded: base64String),
           let uiImage = NSImage(data: imageData) {
            DispatchQueue.main.async {
                self.profileImage = Image(nsImage: uiImage)
                print("✅ Profile image loaded locally for user ID: \(userId), Base64 URL: \(base64String.prefix(20))...")
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
            self.user = result.user
            self.userId = uid // Make sure userId is set here after login
            
            DispatchQueue.main.async {
                self.falseCredential = false
                self.authErrorMessage = ""
                self.isLogin = true
                self.loadLocalProfileImage(userId: uid)
            }
            
            print("✅ SignIn Success for user ID: \(uid), Email: \(userModel.email)")
            
            try await fetchUser(uid: uid)
            await loadColorsFromFirebase()
            
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
    
    func saveColorsToFirebase() async {
        guard let uid = user?.uid else {
            print("Error: User not logged in. Cannot save colors to Firebase.")
            return
        }
        do {
            let encodedColors = try JSONEncoder().encode(unlockedColors)
            let colorsData = try JSONSerialization.jsonObject(with: encodedColors, options: .allowFragments)
            try await db.child("users").child(uid).child("unlockedColors").setValue(colorsData)
            print("✅ Unlocked colors saved to Firebase for user ID: \(uid)")
        } catch {
            print("❌ Error saving unlocked colors to Firebase: \(error.localizedDescription)")
        }
    }
    
    func loadColorsFromFirebase() async {
        guard let uid = user?.uid else {
            print("Error: User not logged in. Cannot load colors from Firebase.")
            return
        }
        do {
            let snapshot = try await db.child("users").child(uid).child("unlockedColors").getData()
            if let value = snapshot.value {
                let jsonData = try JSONSerialization.data(withJSONObject: value, options: [])
                let decodedColors = try JSONDecoder().decode([ColorItem].self, from: jsonData)
                DispatchQueue.main.async {
                    self.unlockedColors = decodedColors
                    print("✅ Unlocked colors loaded from Firebase for user ID: \(uid)")
                }
            } else {
                DispatchQueue.main.async {
                    self.unlockedColors = []
                    self.loadInitialColors()
                    print("⚠️ No unlocked colors found in Firebase for user ID: \(uid), loading initial colors.")
                }
            }
        } catch {
            print("❌ Error loading unlocked colors from Firebase: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.unlockedColors = []
                self.loadInitialColors()
            }
        }
    }
    
    func logout() async {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.userId = nil // Clear userId on logout
            self.isLogin = false
            self.falseCredential = false
            self.userModel = UserModel()
            self.profileImage = nil
            self.unlockedColors = []
            loadInitialColors()
            
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
        Task { await saveColorsToFirebase() }
    }
    
    // Modified addProject function
    func addProject(name: String? = nil, drawing: PKDrawing) {
        // Safely unwrap userId. If nil, print an error and return.
        guard let currentUserId = self.userId else {
            print("❌ Error: Cannot add project. User ID is nil. Please log in or register.")
            // Optionally, you could show an alert to the user here.
            return
        }
        
        let newProjectInMemory = DrawingProject(name: name, drawing: drawing, userId: currentUserId)
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
