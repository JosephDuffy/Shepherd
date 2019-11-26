import XCTest
import Shepherd

final class RouterTests: XCTestCase {

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
        let path = "test-path"

        let parentRouter = MockRouter<String>()
        let parentExpectation = XCTestExpectation(description: "Ask parent to handle path")
        parentRouter.handleDelegate = {
            parentExpectation.fulfill()
        }
        parentRouter.add(child: router)

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

        wait(for: [parentExpectation, expectation], timeout: 1, enforceOrder: true)
    }

    func testEmptyRouterWithParentIgnoringParent() {
        let router = Router()
        let path = "test-path"

        let parentRouter = MockRouter<String>()
        let parentExpectation = XCTestExpectation(description: "Ask parent to handle path")
        parentExpectation.isInverted = true
        parentRouter.handleDelegate = {
            parentExpectation.fulfill()
        }
        parentRouter.add(child: router)

        let expectation = XCTestExpectation(description: "Call completion handler")
        router.handle(path: path, ignoring: [parentRouter]) { handledRouter in
            defer {
                expectation.fulfill()
            }

            XCTAssertNil(handledRouter, "Path should not be handled")
            XCTAssertNil(parentRouter.latestHandleParameters, "Parent should not be called")
        }

        wait(for: [expectation, parentExpectation], timeout: 1, enforceOrder: true)
    }

    func testEmptyRouterWithParentHandlingPath() {
        let router = Router()
        let path = "test-path"

        let parentRouter = MockRouter<String>()
        let parentExpectation = XCTestExpectation(description: "Ask parent to handle path")
        parentRouter.handleDelegate = {
            parentExpectation.fulfill()
        }
        parentRouter.add(child: router)
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

        wait(for: [parentExpectation, expectation], timeout: 1, enforceOrder: true)
    }

    func testRouterWithChildHandlerHandlingPath() {
        let router = Router()
        let path = "test-path"

        let pathHandlerExpectation = XCTestExpectation(description: "Ask closure path handler to handle path")
        let pathHandler = router.addHandlerForPaths(ofType: String.self) { _, completionHandler in
            pathHandlerExpectation.fulfill()
            completionHandler(true)
        }

        let handlePathCompletionHandlerExpectation = XCTestExpectation(description: "Call completion handler")
        router.handle(path: path) { handledRouter in
            handlePathCompletionHandlerExpectation.fulfill()

            XCTAssert(handledRouter === pathHandler, "Path should be handled by closure handler")
        }

        wait(
            for: [
                pathHandlerExpectation,
                handlePathCompletionHandlerExpectation,
            ],
            timeout: 1,
            enforceOrder: true
        )
    }

    func testRouterWithRemovedHandler() {
        let router = Router()
        let path = "test-path"

        let pathHandlerExpectation = XCTestExpectation(description: "Ask closure path handler to handle path")
        pathHandlerExpectation.isInverted = true
        let pathHandler = router.addHandlerForPaths(ofType: String.self, priority: .low) { _, completionHandler in
            pathHandlerExpectation.fulfill()
            completionHandler(false)
        }
        router.remove(child: pathHandler)

        let handlePathCompletionHandlerExpectation = XCTestExpectation(description: "Call completion handler")
        router.handle(path: path) { handledRouter in
            handlePathCompletionHandlerExpectation.fulfill()

            XCTAssertNil(handledRouter, "Path should not be handled")
        }

        wait(
            for: [
                pathHandlerExpectation,
                handlePathCompletionHandlerExpectation,
            ],
            timeout: 1,
            enforceOrder: true
        )
    }

    func testRouterWithMultiplePriorityHandlers() {
        let router = Router()
        let path = "test-path"

        let lowPriorityHandler1Expectation = XCTestExpectation(description: "Ask low priority 1 to handle path")
        router.addHandlerForPaths(ofType: String.self, priority: .low) { _, completionHandler in
            lowPriorityHandler1Expectation.fulfill()
            completionHandler(false)
        }

        let mediumPriorityHandler1Expectation = XCTestExpectation(description: "Ask medium priority 1 to handle path")
        router.addHandlerForPaths(ofType: String.self) { _, completionHandler in
            mediumPriorityHandler1Expectation.fulfill()
            completionHandler(false)
        }

        let highPriorityHandler1Expectation = XCTestExpectation(description: "Ask high priority 1 to handle path")
        router.addHandlerForPaths(ofType: String.self, priority: .high) { _, completionHandler in
            highPriorityHandler1Expectation.fulfill()
            completionHandler(false)
        }

        let lowPriorityHandler2Expectation = XCTestExpectation(description: "Ask low priority 2 to handle path")
        router.addHandlerForPaths(ofType: String.self, priority: .low) { _, completionHandler in            lowPriorityHandler2Expectation.fulfill()
            completionHandler(false)

        }

        let mediumPriorityHandler2Expectation = XCTestExpectation(description: "Ask medium priority 2 to handle path")
        router.addHandlerForPaths(ofType: String.self) { _, completionHandler in
            mediumPriorityHandler2Expectation.fulfill()
            completionHandler(false)
        }

        let highPriorityHandler2Expectation = XCTestExpectation(description: "Ask high priority 2 to handle path")
        router.addHandlerForPaths(ofType: String.self, priority: .high) { _, completionHandler in
            highPriorityHandler2Expectation.fulfill()
            completionHandler(false)
        }

        let oneBelowHighPriorityHandlerExpectation = XCTestExpectation(description: "Ask 999 priority to handle path")
        router.addHandlerForPaths(ofType: String.self, priority: 999) { _, completionHandler in
            oneBelowHighPriorityHandlerExpectation.fulfill()
            completionHandler(false)
        }

        let oneBelowParentPriorityHandlerExpectation = XCTestExpectation(description: "Ask -1 priority to handle path")
        router.addHandlerForPaths(ofType: String.self, priority: Priority(rawValue: -1)) { _, completionHandler in
            oneBelowParentPriorityHandlerExpectation.fulfill()
            completionHandler(false)
        }

        let parentRouter = MockRouter<String>()
        parentRouter.add(child: router)
        let parentExpectation = XCTestExpectation(description: "Ask parent to handle path")
        parentRouter.handleDelegate = {
            parentExpectation.fulfill()
        }

        let handlePathCompletionHandlerExpectation = XCTestExpectation(description: "Call completion handler")
        router.handle(path: path) { handledRouter in
            defer {
                handlePathCompletionHandlerExpectation.fulfill()
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

        wait(
            for: [
                highPriorityHandler1Expectation,
                highPriorityHandler2Expectation,
                oneBelowHighPriorityHandlerExpectation,
                mediumPriorityHandler1Expectation,
                mediumPriorityHandler2Expectation,
                lowPriorityHandler1Expectation,
                lowPriorityHandler2Expectation,
                parentExpectation,
                oneBelowParentPriorityHandlerExpectation,
                handlePathCompletionHandlerExpectation,
            ],
            timeout: 1,
            enforceOrder: true
        )
    }

}
