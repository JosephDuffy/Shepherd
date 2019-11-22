import Quick
import Nimble
@testable import Shepherd

final class RouterTests: QuickSpec {

    override func spec() {
        describe("Router") {
            var router: Router!

            beforeEach {
                router = Router()
            }

            context("with no children, or a parent") {
                context("handle(activity:ignoring:completionHandler:)") {
                    it("should call the completion handler with `nil`") {
                        let path = "path/to/handle"

                        waitUntil { done in
                            router.handle(path: path, ignoring: []) { handledRouter in
                                expect(handledRouter).to(beNil())
                                done()
                            }
                        }
                    }
                }
            }

            context("with a parent") {
                var parentRouter: MockRouter<String>!
                var path: String!

                beforeEach {
                    parentRouter = MockRouter()
                    parentRouter.add(child: router)
                    path = "path/to/handle"
                }

                context("handle(activity:ignoring:completionHandler:)") {
                    it("should call the completion handler with `nil`") {
                        waitUntil { done in
                            router.handle(path: path) { handledRouter in
                                expect(handledRouter).to(beNil())
                                done()
                            }
                        }
                    }

                    it("should call the parent handler with the route") {
                        waitUntil { done in
                            router.handle(path: path) { _ in
                                expect(parentRouter.latestHandleParameters?.path as? String) == path
                                done()
                            }
                        }
                    }

                    context("passing the parent for `ignoring`") {
                        it("should call the completion handler with `nil`") {
                            waitUntil { done in
                                router.handle(path: path, ignoring: [parentRouter]) { handledRouter in
                                    expect(handledRouter).to(beNil())
                                    done()
                                }
                            }
                        }

                        it("should not call the parent handler") {
                            waitUntil { done in
                                router.handle(path: path, ignoring: [parentRouter]) { _ in
                                    expect(parentRouter.latestHandleParameters).to(beNil())
                                    done()
                                }
                            }
                        }
                    }
                }

                context("that can handle the activity") {
                    beforeEach {
                        parentRouter.routeToHandle = path
                    }

                    context("handle(activity:ignoring:completionHandler:)") {
                        it("should call the completion handler with the parent") {
                            waitUntil { done in
                                router.handle(path: path, ignoring: []) { handledRouter in
                                    expect(handledRouter) === parentRouter
                                    done()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

}
