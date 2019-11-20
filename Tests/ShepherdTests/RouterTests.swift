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
                        let activity = "test"

                        waitUntil { done in
                            router.handle(route: activity, ignoring: []) { handledRouter in
                                expect(handledRouter).to(beNil())
                                done()
                            }
                        }
                    }
                }
            }

            context("with a parent") {
                var parentRouter: MockRouter<String>!
                var route: String!

                beforeEach {
                    parentRouter = MockRouter()
                    parentRouter.add(child: router)
                    route = "route-to-handle"
                }

                context("handle(activity:ignoring:completionHandler:)") {
                    it("should call the completion handler with `nil`") {
                        waitUntil { done in
                            router.handle(route: route) { handledRouter in
                                expect(handledRouter).to(beNil())
                                done()
                            }
                        }
                    }

                    it("should call the parent handler with the activity") {
                        waitUntil { done in
                            router.handle(route: route) { handledRouter in
                                expect(parentRouter.latestHandleParameters?.route as? String) == route
                                done()
                            }
                        }
                    }

                    context("passing the parent for `ignoring`") {
                        it("should call the completion handler with `nil`") {
                            waitUntil { done in
                                router.handle(route: route, ignoring: [parentRouter]) { handledRouter in
                                    expect(handledRouter).to(beNil())
                                    done()
                                }
                            }
                        }

                        it("should not call the parent handler") {
                            waitUntil { done in
                                router.handle(route: route, ignoring: [parentRouter]) { handledRouter in
                                    expect(parentRouter.latestHandleParameters).to(beNil())
                                    done()
                                }
                            }
                        }
                    }
                }

                context("that can handle the activity") {
                    beforeEach {
                        parentRouter.routeToHandle = route
                    }

                    context("handle(activity:ignoring:completionHandler:)") {
                        it("should call the completion handler with the parent") {
                            waitUntil { done in
                                router.handle(route: route, ignoring: []) { handledRouter in
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
