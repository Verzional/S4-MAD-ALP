//
//  DrawingViewModelTest.swift
//  S4-MAD-ALPTests
//
//  Created by Gabriela Sihutomo on 08/06/25.
//

import XCTest

final class DrawingViewModelTest: XCTestCase {

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
    
    func testLevelCheck() async throws{
        let viewModel = DrawingViewModel()
        
    }
    
    func testUsePen() async throws{
        let viewModel = DrawingViewModel()
        await viewModel.usePen()
        XCTAssertEqual(viewModel.currentTool, .pen)
    }

    func testUsePencil() async throws{
        let viewModel = DrawingViewModel()
        await viewModel.usePen()
        XCTAssertEqual(viewModel.currentTool, .pencil)
    }

    func testUseMarker() async throws{
        let viewModel = DrawingViewModel()
        await viewModel.useMarker()
        XCTAssertEqual(viewModel.currentTool, .marker)
    }
    
    func testUseCrayon() async throws{
        let viewModel = DrawingViewModel()
        await viewModel.useCrayon()
        XCTAssertEqual(viewModel.currentTool, .crayon)
    }

    func testUseSoftEraser() async throws{
        let viewModel = DrawingViewModel()
        await viewModel.useSoftEraser()
        XCTAssertEqual(viewModel.currentTool, .softEraser)
    }

    func testUseStrokeEraser() async throws{
        let viewModel = DrawingViewModel()
        await viewModel.useStrokeEraser()
        XCTAssertEqual(viewModel.currentTool, .strokeEraser)
    }

    func testUpdateToolColorOrWidth() async throws{
        let viewModel = DrawingViewModel()
    }

    func testClear() async throws{
        let viewModel = DrawingViewModel()
    }
    
    

}
