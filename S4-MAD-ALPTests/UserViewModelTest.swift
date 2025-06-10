//
//  UserViewModel.swift
//  S4-MAD-ALPTests
//
//  Created by Gabriela Sihutomo on 08/06/25.
//

import XCTest
import PencilKit

final class UserViewModelTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    @MainActor
    func testLogin() async throws {
        let viewModel = await UserViewModel()
        await viewModel.userModel.email = "valentinomg7@gmail.com"
        await viewModel.userModel.password = "valenDraws"
        await viewModel.login()
        XCTAssertTrue(viewModel.userId != nil)
        
        
        
        
    }
    
    @MainActor
    func testGainXP() async throws{
        let viewModel = await UserViewModel()
        await viewModel.gainXP(xp: 50)
        XCTAssert(viewModel.userModel.level == 1)
        
        
    }
    
    @MainActor
    func testAddDeleteProject() async throws{
        let viewModel = await UserViewModel()
        await viewModel.userModel.email = "valentinomg7@gmail.com"
        await viewModel.userModel.password = "valenDraws"
        await viewModel.login()
        
        await viewModel.addProject(name: "TestProject", drawing: PKDrawing())
        
        XCTAssertTrue(viewModel.projects.count == 1)
        
        await viewModel.deleteProject(viewModel.projects[0])
        
        XCTAssertTrue(viewModel.projects.isEmpty)
        
        
        
    }
    

    
    
    
    

}
