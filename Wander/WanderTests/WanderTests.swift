//
//  WanderTests.swift
//  WanderTests
//
//  Created by Ankita on 22.05.21.
//

import XCTest
@testable import Wander

class WanderTests: XCTestCase {
    
    let viewModel = WNPhotoViewModel()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let photoExpectation = expectation(description: "photos")
        viewModel.getPhoto(lat: 49.902550, long: 10.884520)
        waitForExpectations(timeout: 60) { (error) in
            photoExpectation.fulfill()
            XCTAssertNotNil(self.viewModel.photoItems)
          }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
