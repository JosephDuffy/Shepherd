import XCTest
@testable import Shepherd

final class XCRouterTests: XCTestCase {

    func testEmptyRouter() {
        let router = Router()

        let expectation = XCTestExpectation(description: "Call completion handler")

        router.handle(path: "test-path") { handledRouter in
            defer {
                expectation.fulfill()
            }

            XCTAssertNil(handledRouter, "Path should not be handled")
        }

        wait(for: [expectation], timeout: 1)
    }

    func testEmptyRouterWithParent() {
        let router = Router()
        let parentRouter = MockRouter<String>()
        parentRouter.add(child: router)
        let path = "test-path"

        let expectation = XCTestExpectation(description: "Call completion handler")

        router.handle(path: path) { handledRouter in
            defer {
                expectation.fulfill()
            }

            XCTAssertNil(handledRouter, "Path should not be handled")

            if let latestHandleParameters = parentRouter.latestHandleParameters {
                XCTAssertEqual(latestHandleParameters.path as? String, path)
                XCTAssertEqual(latestHandleParameters.ignoring.count, 1)
                XCTAssert(latestHandleParameters.ignoring.first === router)
            } else {
                XCTFail("Router should query parent")
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testEmptyRouterWithParentIgnoringParent() {
        let router = Router()
        let parentRouter = MockRouter<String>()
        parentRouter.add(child: router)
        let path = "test-path"

        let expectation = XCTestExpectation(description: "Call completion handler")

        router.handle(path: path, ignoring: [parentRouter]) { handledRouter in
            defer {
                expectation.fulfill()
            }

            XCTAssertNil(handledRouter, "Path should not be handled")
            XCTAssertNil(parentRouter.latestHandleParameters, "Parent should not be called")
        }

        wait(for: [expectation], timeout: 1)
    }

    func testEmptyRouterWithParentHandlingPath() {
        let router = Router()
        let parentRouter = MockRouter<String>()
        parentRouter.add(child: router)
        let path = "test-path"
        parentRouter.routeToHandle = path

        let expectation = XCTestExpectation(description: "Call completion handler")

        router.handle(path: path) { handledRouter in
            defer {
                expectation.fulfill()
            }

            XCTAssert(parentRouter === handledRouter, "Should pass parent to completion handler")

            if let latestHandleParameters = parentRouter.latestHandleParameters {
                XCTAssertEqual(latestHandleParameters.path as? String, path)
                XCTAssertEqual(latestHandleParameters.ignoring.count, 1)
                XCTAssert(latestHandleParameters.ignoring.first === router)
            } else {
                XCTFail("Router should query parent")
            }
        }

        wait(for: [expectation], timeout: 1)
    }

}
