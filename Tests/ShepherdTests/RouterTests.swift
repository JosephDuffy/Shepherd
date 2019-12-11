import XCTest
import Shepherd

// Shouldn't trigger a warning
typealias ALargeTuple = (Int, Int, Int, Int, Int)

// Should trigger a warning






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

        XCTAssertTrue(router.children.isEmpty)
        XCTAssertTrue(router.parents.isEmpty)
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
                AssertRouterArrayEqual(latestHandleParameters.ignoring, [router])
            } else {
                XCTFail("Router should query parent")
            }
        }

        XCTAssertTrue(router.children.isEmpty)
        AssertRouterArrayEqual(router.parents, [parentRouter])
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

        XCTAssertTrue(router.children.isEmpty)
        AssertRouterArrayEqual(router.parents, [parentRouter])
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
                AssertRouterArrayEqual(latestHandleParameters.ignoring, [router])
            } else {
                XCTFail("Router should query parent")
            }
        }

        XCTAssertTrue(router.children.isEmpty)
        AssertRouterArrayEqual(router.parents, [parentRouter])
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

    func testRouterWithChildRouter() {
        let parentRouter = Router()
        let childRouter = Router()
        parentRouter.add(child: childRouter)

        AssertRouterArrayEqual(parentRouter.children, [childRouter])
        XCTAssert(childRouter.parent === parentRouter, "Adding child should set the parent")
        AssertRouterArrayEqual(childRouter.parents, [parentRouter])

        parentRouter.remove(child: childRouter)
        XCTAssertNil(childRouter.parent, "Parent should be set to nil after removal")
        XCTAssertTrue(childRouter.parents.isEmpty)
    }

    func testRouterRemovingNonChildRouter() {
        let parentRouter1 = Router()
        let parentRouter2 = Router()
        let childRouter1 = Router()
        let childRouter2 = Router()
        parentRouter1.add(child: childRouter1)
        parentRouter2.add(child: childRouter2)
        parentRouter2.remove(child: childRouter1)
        AssertRouterArrayEqual(parentRouter1.children, [childRouter1])
        AssertRouterArrayEqual(parentRouter2.children, [childRouter2])
        XCTAssert(childRouter1.parent === parentRouter1, "Child's parent should not be unset by a different parent")
        XCTAssert(childRouter2.parent === parentRouter2, "Child's parent should not be unset when removing a different child")
    }

    func testRouterWithMultipleParents() {
        let parentRouter1 = Router()
        let parentRouter2 = Router()
        let parentRouter3 = Router()

        parentRouter1.add(child: parentRouter2)
        parentRouter2.add(child: parentRouter3)

        AssertRouterArrayEqual(parentRouter2.parents, [parentRouter1])
        AssertRouterArrayEqual(parentRouter3.parents, [parentRouter2, parentRouter1])
    }

    func testRemovingWithMultipleChildren() {
        let parentRouter = Router()
        let childRouter1 = Router()
        let childRouter2 = Router()
        let childRouter3 = Router()
        let childRouterHigh1 = Router()
        let childRouterHigh2 = Router()
        let childRouterHigh3 = Router()
        parentRouter.add(child: childRouter1)
        parentRouter.add(child: childRouter2)
        parentRouter.add(child: childRouter3)
        parentRouter.add(child: childRouterHigh1, priority: .high)
        parentRouter.add(child: childRouterHigh2, priority: .high)
        parentRouter.add(child: childRouterHigh3, priority: .high)

        parentRouter.remove(child: childRouter2)
        parentRouter.remove(child: childRouterHigh3)

        AssertRouterArrayEqual(parentRouter.children, [childRouterHigh1, childRouterHigh2, childRouter1, childRouter3])
    }

    func testRouterWithMultiplePriorityHandlers() {
        let router = Router()
        let path = "test-path"

        let lowPriorityHandler1Expectation = XCTestExpectation(description: "Ask low priority 1 to handle path")
        let lowPriorityHandler1 = router.addHandlerForPaths(ofType: String.self, priority: .low) { _, completionHandler in
            lowPriorityHandler1Expectation.fulfill()
            completionHandler(false)
        }

        let mediumPriorityHandler1Expectation = XCTestExpectation(description: "Ask medium priority 1 to handle path")
        let mediumPriorityHandler1 = router.addHandlerForPaths(ofType: String.self) { _, completionHandler in
            mediumPriorityHandler1Expectation.fulfill()
            completionHandler(false)
        }

        let highPriorityHandler1Expectation = XCTestExpectation(description: "Ask high priority 1 to handle path")
        let highPriorityHandler1 = router.addHandlerForPaths(ofType: String.self, priority: .high) { _, completionHandler in
            highPriorityHandler1Expectation.fulfill()
            completionHandler(false)
        }

        let lowPriorityHandler2Expectation = XCTestExpectation(description: "Ask low priority 2 to handle path")
        let lowPriorityHandler2 = router.addHandlerForPaths(ofType: String.self, priority: .low) { _, completionHandler in            lowPriorityHandler2Expectation.fulfill()
            completionHandler(false)
        }

        let mediumPriorityHandler2Expectation = XCTestExpectation(description: "Ask medium priority 2 to handle path")
        let mediumPriorityHandler2 = router.addHandlerForPaths(ofType: String.self) { _, completionHandler in
            mediumPriorityHandler2Expectation.fulfill()
            completionHandler(false)
        }

        let highPriorityHandler2Expectation = XCTestExpectation(description: "Ask high priority 2 to handle path")
        let highPriorityHandler2 = router.addHandlerForPaths(ofType: String.self, priority: .high) { _, completionHandler in
            highPriorityHandler2Expectation.fulfill()
            completionHandler(false)
        }

        let updatedLowToHighPriorityExpectation = XCTestExpectation(description: "Ask updated low to high priority to handle path")
        let updatedLowToHighPriorityHandler = router.addHandlerForPaths(ofType: String.self, priority: .low) { _, completionHandler in
            updatedLowToHighPriorityExpectation.fulfill()
            completionHandler(false)
        }
        router.add(child: updatedLowToHighPriorityHandler, priority: .high)

        let oneBelowHighPriorityHandlerExpectation = XCTestExpectation(description: "Ask 999 priority to handle path")
        let oneBelowHighPriorityHandler = router.addHandlerForPaths(ofType: String.self, priority: 999) { _, completionHandler in
            oneBelowHighPriorityHandlerExpectation.fulfill()
            completionHandler(false)
        }

        let oneBelowParentPriorityHandlerExpectation = XCTestExpectation(description: "Ask -1 priority to handle path")
        let oneBelowParentPriorityHandler = router.addHandlerForPaths(ofType: String.self, priority: Priority(rawValue: -1)) { _, completionHandler in
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
                AssertRouterArrayEqual(latestHandleParameters.ignoring, [router])
            } else {
                XCTFail("Router should query parent")
            }
        }

        AssertRouterArrayEqual(
            router.children,
            [
                highPriorityHandler1,
                highPriorityHandler2,
                updatedLowToHighPriorityHandler,
                oneBelowHighPriorityHandler,
                mediumPriorityHandler1,
                mediumPriorityHandler2,
                lowPriorityHandler1,
                lowPriorityHandler2,
                oneBelowParentPriorityHandler,
            ],
            "Children should be ordered by priority"
        )
        AssertRouterArrayEqual(parentRouter.children, [router], "Children should only contain the immediate child")
        wait(
            for: [
                highPriorityHandler1Expectation,
                highPriorityHandler2Expectation,
                updatedLowToHighPriorityExpectation,
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

func AssertRouterArrayEqual(_ expression1: @autoclosure () throws -> [Router], _ expression2: @autoclosure () throws -> [Router], _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) rethrows {
    let array1 = try expression1()
    let array2 = try expression2()
    guard array1.count == array2.count else {
        XCTFail(message() + ". Array \(array1) did not equal \(array2)", file: file, line: line)
        return
    }

    for (index, element1) in array1.enumerated() {
        let element2 = array2[index]
        if element1 !== element2 {
            XCTFail(message() + ". Array \(array1) did not equal \(array2)", file: file, line: line)
            return
        }
    }
}
