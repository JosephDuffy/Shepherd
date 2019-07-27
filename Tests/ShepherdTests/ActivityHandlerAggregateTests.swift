import Foundation
import Quick
import Nimble
@testable import Shepherd

final class ActivityHandlerAggregateTests: QuickSpec {

    override func spec() {
        describe("ActivityHandlerAggregate") {
            var activityHandler: ActivityHandlerAggregate!

            beforeEach {
                activityHandler = ActivityHandlerAggregate()
            }

            context("append(_:)") {
                var child: ActivityHandler!

                beforeEach {
                    child = ActivityHandler()
                    activityHandler.append(child)
                }

                it("should set the parent of the child to itself") {
                    expect(child.parent) === activityHandler
                }

                it("should add the child to the array of children") {
                    expect(activityHandler.children).to(containElementSatisfying({ $0 === child }))
                }
            }

            context("remove(_:)") {
                var child: ActivityHandler!

                beforeEach {
                    child = ActivityHandler()
                    activityHandler.append(child)
                    activityHandler.remove(child)
                }

                it("should set the parent of the child to nil") {
                    expect(child.parent).to(beNil())
                }

                it("should remove the child from the array of children") {
                    expect(activityHandler.children).toNot(containElementSatisfying({ $0 === child }))
                }
            }

            context("with 3 children") {
                var activity: NSUserActivity!
                var child1: MockActivityHandler!
                var child2: MockActivityHandler!
                var child3: MockActivityHandler!

                beforeEach {
                    activity = NSUserActivity(activityType: "test-activity")

                    child1 = MockActivityHandler()
                    child2 = MockActivityHandler()
                    child3 = MockActivityHandler()

                    activityHandler.append(child1)
                    activityHandler.append(child2)
                    activityHandler.append(child3)
                }

                context("when no children can handle the activity") {
                    context("handle(activity:ignoring:)") {
                        var result: ActivityHandler?

                        beforeEach {
                            result = activityHandler.handle(activity: activity, ignoring: nil)
                        }

                        it("should call the first activity handler with the passed activity") {
                            expect(child1.latestHandleActivityParameters?.activity) === activity
                        }

                        it("should call the first activity handler ignoring itself") {
                            expect(child1.latestHandleActivityParameters?.ignoring) === activityHandler
                        }

                        it("should call the second activity handler with the passed activity") {
                            expect(child1.latestHandleActivityParameters?.activity) === activity
                        }

                        it("should call the second activity handler ignoring itself") {
                            expect(child1.latestHandleActivityParameters?.ignoring) === activityHandler
                        }

                        it("should call the third activity handler with the passed activity") {
                            expect(child1.latestHandleActivityParameters?.activity) === activity
                        }

                        it("should call the third activity handler ignoring itself") {
                            expect(child1.latestHandleActivityParameters?.ignoring) === activityHandler
                        }

                        it("should return nil") {
                            expect(result).to(beNil())
                        }
                    }
                }

                context("when the first child can handle the activity") {
                    beforeEach {
                        child1.activityToHandle = activity
                    }

                    context("handle(activity:ignoring:)") {
                        var result: ActivityHandler?

                        beforeEach {
                            result = activityHandler.handle(activity: activity, ignoring: nil)
                        }

                        it("should call the first activity handler with the passed activity") {
                            expect(child1.latestHandleActivityParameters?.activity) === activity
                        }

                        it("should call the first activity handler ignoring itself") {
                            expect(child1.latestHandleActivityParameters?.ignoring) === activityHandler
                        }

                        it("should return the first activity handler") {
                            expect(result) === child1
                        }

                        it("should not call the second activity handler") {
                            expect(child2.latestHandleActivityParameters).to(beNil())
                        }

                        it("should not call the third activity handler") {
                            expect(child3.latestHandleActivityParameters).to(beNil())
                        }
                    }
                }

                context("when the second child can handle the activity") {
                    beforeEach {
                        child2.activityToHandle = activity
                    }

                    context("handle(activity:ignoring:)") {
                        var result: ActivityHandler?

                        beforeEach {
                            result = activityHandler.handle(activity: activity, ignoring: nil)
                        }

                        it("should call the first activity handler with the passed activity") {
                            expect(child1.latestHandleActivityParameters?.activity) === activity
                        }

                        it("should call the first activity handler ignoring itself") {
                            expect(child1.latestHandleActivityParameters?.ignoring) === activityHandler
                        }

                        it("should call the second activity handler with the passed activity") {
                            expect(child2.latestHandleActivityParameters?.activity) === activity
                        }

                        it("should call the second activity handler ignoring itself") {
                            expect(child2.latestHandleActivityParameters?.ignoring) === activityHandler
                        }

                        it("should return the second activity handler") {
                            expect(result) === child2
                        }

                        it("should not call the third activity handler") {
                            expect(child3.latestHandleActivityParameters).to(beNil())
                        }
                    }
                }

                context("when the third child can handle the activity") {
                    beforeEach {
                        child3.activityToHandle = activity
                    }

                    context("handle(activity:ignoring:)") {
                        var result: ActivityHandler?

                        beforeEach {
                            result = activityHandler.handle(activity: activity, ignoring: nil)
                        }

                        it("should call the first activity handler with the passed activity") {
                            expect(child1.latestHandleActivityParameters?.activity) === activity
                        }

                        it("should call the first activity handler ignoring itself") {
                            expect(child1.latestHandleActivityParameters?.ignoring) === activityHandler
                        }

                        it("should call the second activity handler with the passed activity") {
                            expect(child2.latestHandleActivityParameters?.activity) === activity
                        }

                        it("should call the second activity handler ignoring itself") {
                            expect(child2.latestHandleActivityParameters?.ignoring) === activityHandler
                        }

                        it("should call the third activity handler with the passed activity") {
                            expect(child3.latestHandleActivityParameters?.activity) === activity
                        }

                        it("should call the third activity handler ignoring itself") {
                            expect(child3.latestHandleActivityParameters?.ignoring) === activityHandler
                        }

                        it("should return the third activity handler") {
                            expect(result) === child3
                        }
                    }
                }
            }

            context("with a parent") {
                var parent: MockActivityHandlerAggregate!

                beforeEach {
                    parent = MockActivityHandlerAggregate()
                    activityHandler.parent = parent
                }

                context("handle(activity:ignoring:)") {
                    var activity: NSUserActivity!

                    beforeEach {
                        activity = NSUserActivity(activityType: "test-activity")
                    }

                    context("passing `nil` to `ignoring`") {
                        var result: ActivityHandler?

                        beforeEach {
                            result = activityHandler.handle(activity: activity, ignoring: nil)
                        }

                        it("should call `handle(activity:ignoring:) on the parent") {
                            expect(parent.latestHandleActivityParameters).toNot(beNil())
                        }

                        it("should pass the activity to the parent") {
                            expect(parent.latestHandleActivityParameters?.activity) == activity
                        }

                        it("should pass itself to the parent") {
                            expect(parent.latestHandleActivityParameters?.ignoring) === activityHandler
                        }

                        it("should return `nil`") {
                            expect(result).to(beNil())
                        }
                    }

                    context("passing the parent to `ignoring`") {
                        var result: ActivityHandler?

                        beforeEach {
                            result = activityHandler.handle(activity: activity, ignoring: parent)
                        }

                        it("should not call `handle(activity:ignoring:) on the parent") {
                            expect(parent.latestHandleActivityParameters).to(beNil())
                        }

                        it("should return `nil`") {
                            expect(result).to(beNil())
                        }
                    }
                }

                context("when all other references to the parent has been nilled") {
                    beforeEach {
                        parent = nil
                    }

                    it("should not have a parent") {
                        expect(activityHandler.parent).to(beNil())
                    }
                }
            }
        }
    }

}
