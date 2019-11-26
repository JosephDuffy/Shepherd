import XCTest
import Shepherd

final class ClosurePathHandlerTests: XCTestCase {

    func testClosurePathHandlerWithDifferentPathType() {
        let router = Router()
        let path = "test-path"

        let intPathHandlerExpectation = XCTestExpectation(description: "Ask Int handler to handle path")
        intPathHandlerExpectation.isInverted = true
        router.addHandlerForPaths(ofType: Int.self, priority: .low) { _, completionHandler in
            intPathHandlerExpectation.fulfill()
            completionHandler(false)
        }

        let handlePathCompletionHandlerExpectation = XCTestExpectation(description: "Call completion handler")
        router.handle(path: path) { handledRouter in
            handlePathCompletionHandlerExpectation.fulfill()

            XCTAssertNil(handledRouter, "Path should not be handled")
        }

        wait(
            for: [
                intPathHandlerExpectation,
                handlePathCompletionHandlerExpectation,
            ],
            timeout: 1,
            enforceOrder: true
        )
    }

}
