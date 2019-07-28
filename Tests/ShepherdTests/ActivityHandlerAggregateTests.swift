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

            context("with a child added via append(_:) that is held on to strongly") {
                var child: ActivityHandler!

                beforeEach {
                    child = ActivityHandler()
                    activityHandler.append(child, heldOnTo: .strongly)
                }

                it("should set the parent of the child to itself") {
                    expect(child.parent) === activityHandler
                }

                it("should add the child to the array of children") {
                    expect(activityHandler.children).to(containElementSatisfying({ $0 === child }))
                }

                context("then removed via remove(_:)") {
                    beforeEach {
                        activityHandler.remove(child)
                    }

                    it("should set the parent of the child to nil") {
                        expect(child.parent).to(beNil())
                    }

                    it("should have no children") {
                        expect(activityHandler.children).to(beEmpty())
                    }
                }
            }

            context("with a child added via append(_:) that is held on to weakly") {
                var child: ActivityHandler!

                beforeEach {
                    child = ActivityHandler()
                    activityHandler.append(child, heldOnTo: .weakly)
                }

                it("should set the parent of the child to itself") {
                    expect(child.parent) === activityHandler
                }

                it("should add the child to the array of children") {
                    expect(activityHandler.children).to(containElementSatisfying({ $0 === child }))
                }

                context("then removed via remove(_:)") {
                    beforeEach {
                        activityHandler.remove(child)
                    }

                    it("should set the parent of the child to nil") {
                        expect(child.parent).to(beNil())
                    }

                    it("should have no children") {
                        expect(activityHandler.children).to(beEmpty())
                    }
                }
            }

            context("passing an activity handler that is not a child to `remove(_:)`") {
                var child: ActivityHandler!
                var parent: ActivityHandlerAggregate!

                beforeEach {
                    child = ActivityHandler()
                    parent = ActivityHandlerAggregate()
                    parent.append(child, heldOnTo: .weakly)

                    activityHandler.remove(child)
                }

                it("should not set the parent property on the activity handler") {
                    expect(child.parent) === parent
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

                    activityHandler.append(child1, heldOnTo: .weakly)
                    activityHandler.append(child2, heldOnTo: .weakly)
                    activityHandler.append(child3, heldOnTo: .weakly)
                }

                context("when no children can handle the activity") {
                    context("handle(activity:ignoring:)") {
                        context("passing `nil` for `ignoring`") {
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

                            it("should return nil") {
                                expect(result).to(beNil())
                            }
                        }

                        context("passing the first child for `ignoring`") {
                            var result: ActivityHandler?

                            beforeEach {
                                result = activityHandler.handle(activity: activity, ignoring: child1)
                            }

                            it("should not call the first activity handler") {
                                expect(child1.latestHandleActivityParameters).to(beNil())
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

                            it("should return nil") {
                                expect(result).to(beNil())
                            }
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
        }
    }

}
