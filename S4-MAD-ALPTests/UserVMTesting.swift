import XCTest
import Firebase
import FirebaseAuth
import SwiftUI
@testable import S4_MAD_ALP

@MainActor
final class UserVMTesting: XCTestCase {

    var viewModel: UserViewModel!

    override func setUpWithError() throws {
        viewModel = UserViewModel()
    }

    override func tearDownWithError() throws {
        viewModel = nil
    }

    func testLogout() async throws {
        viewModel.isLogin = true
        viewModel.user = Auth.auth().currentUser
        viewModel.userModel = UserModel(name: "Test", email: "test@example.com", password: "123456")
        viewModel.profileImage = Image(systemName: "person")

        await viewModel.logout()

        XCTAssertNil(viewModel.user)
        XCTAssertFalse(viewModel.isLogin)
        XCTAssertFalse(viewModel.falseCredential)
        XCTAssertEqual(viewModel.userModel.name, "")
        XCTAssertEqual(viewModel.userModel.email, "")
        XCTAssertEqual(viewModel.userModel.password, "")
        XCTAssertNil(viewModel.profileImage)
    }

    func testSaveAndLoadLocalProfileImage() {
        let testUserId = "test_user_id"
        let testUIImage = UIImage(systemName: "person.fill")!
        let imageData = testUIImage.pngData()!

        viewModel.saveLocalProfileImage(userId: testUserId, imageData: imageData)
        viewModel.loadLocalProfileImage(userId: testUserId)

        let expectation = XCTestExpectation(description: "Wait for image to load")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertNotNil(self.viewModel.profileImage, "Profile image should be loaded from UserDefaults")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testFetchUserFailsWithInvalidUID() async throws {
        do {
            try await viewModel.fetchUser(uid: "invalid_uid_123")
            // Expecting empty userModel
            XCTAssertEqual(viewModel.userModel.name, "")
            XCTAssertEqual(viewModel.userModel.email, "")
        } catch {
            XCTFail("Fetching user with invalid UID should not throw, got error: \(error)")
        }
    }
    
    func testGainXPLevelUp() {
        let viewModel = UserViewModel()
        viewModel.userModel.currXP = 95
        viewModel.userModel.maxXP = 100
        viewModel.userModel.level = 1

        viewModel.gainXP(xp: 10)

        XCTAssertEqual(viewModel.userModel.level, 2)
        XCTAssertEqual(viewModel.userModel.currXP, 5)
        XCTAssertTrue(viewModel.userModel.maxXP > 100)
    }

    func testGainXPWithoutLevelUp() {
        let viewModel = UserViewModel()
        viewModel.userModel.currXP = 40
        viewModel.userModel.maxXP = 100
        viewModel.userModel.level = 1

        viewModel.gainXP(xp: 20)

        XCTAssertEqual(viewModel.userModel.level, 1)
        XCTAssertEqual(viewModel.userModel.currXP, 60)
    }

    
}
