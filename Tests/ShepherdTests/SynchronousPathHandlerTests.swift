import XCTest
import Shepherd

final class SynchronousPathHandlerTests: XCTestCase {

    func testAsyncMethod() {
        let handler = MockSynchronousPathHandler<String>()
        let handlerToReturn = MockSynchronousPathHandler<Int>()
        handler.pathHandlerToReturn = handlerToReturn
        let path = "test-path"

        let handlePathCompletionHandlerExpectation = XCTestExpectation(description: "Call completion handler")
        handler.handle(path: path) { handledRouter in
            handlePathCompletionHandlerExpectation.fulfill()

            XCTAssert(handledRouter === handlerToReturn)
            XCTAssert(handler.latestHandlePath as? String == path)
        }

        wait(for: [handlePathCompletionHandlerExpectation], timeout: 1)
    }

}
