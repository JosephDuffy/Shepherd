import Foundation
import Quick
import Nimble
@testable import Shepherd

final class StackingActivityHandlerAggregateTests: QuickSpec {

    override func spec() {
        describe("StackingActivityHandlerAggregate") {
            var activityHandler: StackingActivityHandlerAggregate!

            beforeEach {
                activityHandler = StackingActivityHandlerAggregate()
            }

            context("with no stacked handler, children, or a parent") {
                context("handle(activity:ignoring:) passing `nil` for `ignoring`") {
                    var result: ActivityHandler?

                    beforeEach {
                        let activity = NSUserActivity(activityType: "test")
                        result = activityHandler.handle(activity: activity, ignoring: nil)
                    }

                    it("should return `nil`") {
                        expect(result).to(beNil())
                    }
                }
            }

            context("with a stacked handler, a child, and a parent") {
                var stackedHandler: MockActivityHandler!
                var childHandler: MockActivityHandler!
                var parentHandler: MockActivityHandlerAggregate!

                beforeEach {
                    stackedHandler = MockActivityHandler()
                    childHandler = MockActivityHandler()
                    parentHandler = MockActivityHandlerAggregate()
                    activityHandler.stack(stackedHandler, heldOnTo: .weakly)
                    activityHandler.append(childHandler, heldOnTo: .weakly)
                    parentHandler.append(activityHandler, heldOnTo: .weakly)
                }

                context("handle(activity:ignoring:) passing `nil` for `ignoring`") {
                    var result: ActivityHandler?

                    beforeEach {
                        let activity = NSUserActivity(activityType: "test")
                        result = activityHandler.handle(activity: activity, ignoring: nil)
                    }

                    it("should return `nil`") {
                        expect(result).to(beNil())
                    }
                }

                context("when the stacked handler can handle the activity") {
                    var activity: NSUserActivity!

                    beforeEach {
                        activity = NSUserActivity(activityType: "test")
                        stackedHandler.activityToHandle = activity
                    }

                    context("handle(activity:ignoring:) passing `nil` for `ignoring`") {
                        var result: ActivityHandler?

                        beforeEach {
                            result = activityHandler.handle(activity: activity, ignoring: nil)
                        }

                        it("should call the stacked handler with the activity") {
                            expect(stackedHandler.latestHandleActivityParameters?.activity) === activity
                        }

                        it("should call the stacked handler ignoring itself") {
                            expect(stackedHandler.latestHandleActivityParameters?.ignoring) === activityHandler
                        }

                        it("should return the stacked handler") {
                            expect(result) === stackedHandler
                        }

                        it("should not ask the child to handle activity") {
                            expect(childHandler.latestHandleActivityParameters).to(beNil())
                        }

                        it("should not ask the parent to handle activity") {
                            expect(parentHandler.latestHandleActivityParameters).to(beNil())
                        }
                    }

                    context("handle(activity:ignoring:) passing the stacked handler for `ignoring`") {
                        var result: ActivityHandler?

                        beforeEach {
                            result = activityHandler.handle(activity: activity, ignoring: stackedHandler)
                        }

                        it("should not ask the stacked handler to handle activity") {
                            expect(stackedHandler.latestHandleActivityParameters).to(beNil())
                        }

                        it("should call the child handler with the activity") {
                            expect(childHandler.latestHandleActivityParameters?.activity) === activity
                        }

                        it("should call the child handler ignoring itself") {
                            expect(childHandler.latestHandleActivityParameters?.ignoring) === activityHandler
                        }

                        it("should call the parent handler with the activity") {
                            expect(parentHandler.latestHandleActivityParameters?.activity) === activity
                        }

                        it("should call the parent handler ignoring itself") {
                            expect(parentHandler.latestHandleActivityParameters?.ignoring) === activityHandler
                        }

                        it("should return `nil`") {
                            expect(result).to(beNil())
                        }
                    }
                }

                context("when the child handler can handle the activity") {
                    var activity: NSUserActivity!

                    beforeEach {
                        activity = NSUserActivity(activityType: "test")
                        childHandler.activityToHandle = activity
                    }

                    context("handle(activity:ignoring:) passing `nil` for `ignoring`") {
                        var result: ActivityHandler?

                        beforeEach {
                            result = activityHandler.handle(activity: activity, ignoring: nil)
                        }

                        it("should call the stacked handler with the activity") {
                            expect(stackedHandler.latestHandleActivityParameters?.activity) === activity
                        }

                        it("should call the stacked handler ignoring itself") {
                            expect(stackedHandler.latestHandleActivityParameters?.ignoring) === activityHandler
                        }

                        it("should call the child handler with the activity") {
                            expect(childHandler.latestHandleActivityParameters?.activity) === activity
                        }

                        it("should call the child handler ignoring itself") {
                            expect(childHandler.latestHandleActivityParameters?.ignoring) === activityHandler
                        }

                        it("should return the child handler") {
                            expect(result) === childHandler
                        }

                        it("should not ask the parent to handle activity") {
                            expect(parentHandler.latestHandleActivityParameters).to(beNil())
                        }
                    }

                    context("handle(activity:ignoring:) passing the stacked handler for `ignoring`") {
                        var result: ActivityHandler?

                        beforeEach {
                            result = activityHandler.handle(activity: activity, ignoring: stackedHandler)
                        }

                        it("should not ask the stacked handler to handle activity") {
                            expect(stackedHandler.latestHandleActivityParameters).to(beNil())
                        }

                        it("should call the child handler with the activity") {
                            expect(childHandler.latestHandleActivityParameters?.activity) === activity
                        }

                        it("should call the child handler ignoring itself") {
                            expect(childHandler.latestHandleActivityParameters?.ignoring) === activityHandler
                        }

                        it("should return the child handler") {
                            expect(result) === childHandler
                        }

                        it("should not ask the parent handler to handle the activity") {
                            expect(parentHandler.latestHandleActivityParameters).to(beNil())
                        }
                    }

                    context("handle(activity:ignoring:) passing the child for `ignoring`") {
                        var result: ActivityHandler?

                        beforeEach {
                            result = activityHandler.handle(activity: activity, ignoring: childHandler)
                        }

                        it("should call the stacked handler with the activity") {
                            expect(stackedHandler.latestHandleActivityParameters?.activity) === activity
                        }

                        it("should call the stacked handler ignoring itself") {
                            expect(stackedHandler.latestHandleActivityParameters?.ignoring) === activityHandler
                        }

                        it("should not ask the child to handle activity") {
                            expect(childHandler.latestHandleActivityParameters).to(beNil())
                        }

                        it("should call the parent handler with the activity") {
                            expect(parentHandler.latestHandleActivityParameters?.activity) === activity
                        }

                        it("should call the parent handler ignoring itself") {
                            expect(parentHandler.latestHandleActivityParameters?.ignoring) === activityHandler
                        }

                        it("should return `nil`") {
                            expect(result).to(beNil())
                        }
                    }
                }

                context("when the parent handler can handle the activity") {
                    var activity: NSUserActivity!

                    beforeEach {
                        activity = NSUserActivity(activityType: "test")
                        parentHandler.activityToHandle = activity
                    }

                    context("handle(activity:ignoring:) passing `nil` for `ignoring`") {
                        var result: ActivityHandler?

                        beforeEach {
                            result = activityHandler.handle(activity: activity, ignoring: nil)
                        }

                        it("should call the stacked handler with the activity") {
                            expect(stackedHandler.latestHandleActivityParameters?.activity) === activity
                        }

                        it("should call the stacked handler ignoring itself") {
                            expect(stackedHandler.latestHandleActivityParameters?.ignoring) === activityHandler
                        }

                        it("should call the child handler with the activity") {
                            expect(childHandler.latestHandleActivityParameters?.activity) === activity
                        }

                        it("should call the child handler ignoring itself") {
                            expect(childHandler.latestHandleActivityParameters?.ignoring) === activityHandler
                        }

                        it("should call the parent handler with the activity") {
                            expect(parentHandler.latestHandleActivityParameters?.activity) === activity
                        }

                        it("should call the parent handler ignoring itself") {
                            expect(parentHandler.latestHandleActivityParameters?.ignoring) === activityHandler
                        }

                        it("should return the parent handler") {
                            expect(result) === parentHandler
                        }
                    }

                    context("handle(activity:ignoring:) passing the stacked handler for `ignoring`") {
                        var result: ActivityHandler?

                        beforeEach {
                            result = activityHandler.handle(activity: activity, ignoring: stackedHandler)
                        }

                        it("should not ask the stacked handler to handle activity") {
                            expect(stackedHandler.latestHandleActivityParameters).to(beNil())
                        }

                        it("should call the child handler with the activity") {
                            expect(childHandler.latestHandleActivityParameters?.activity) === activity
                        }

                        it("should call the child handler ignoring itself") {
                            expect(childHandler.latestHandleActivityParameters?.ignoring) === activityHandler
                        }

                        it("should call the parent handler with the activity") {
                            expect(parentHandler.latestHandleActivityParameters?.activity) === activity
                        }

                        it("should call the parent handler ignoring itself") {
                            expect(parentHandler.latestHandleActivityParameters?.ignoring) === activityHandler
                        }

                        it("should return the parent handler") {
                            expect(result) === parentHandler
                        }
                    }

                    context("handle(activity:ignoring:) passing the child for `ignoring`") {
                        var result: ActivityHandler?

                        beforeEach {
                            result = activityHandler.handle(activity: activity, ignoring: childHandler)
                        }

                        it("should call the stacked handler with the activity") {
                            expect(stackedHandler.latestHandleActivityParameters?.activity) === activity
                        }

                        it("should call the stacked handler ignoring itself") {
                            expect(stackedHandler.latestHandleActivityParameters?.ignoring) === activityHandler
                        }

                        it("should not ask the child to handle activity") {
                            expect(childHandler.latestHandleActivityParameters).to(beNil())
                        }

                        it("should call the parent handler with the activity") {
                            expect(parentHandler.latestHandleActivityParameters?.activity) === activity
                        }

                        it("should call the parent handler ignoring itself") {
                            expect(parentHandler.latestHandleActivityParameters?.ignoring) === activityHandler
                        }

                        it("should return the parent") {
                            expect(result) === parentHandler
                        }
                    }

                    context("handle(activity:ignoring:) passing the parent for `ignoring`") {
                        var result: ActivityHandler?

                        beforeEach {
                            result = activityHandler.handle(activity: activity, ignoring: parentHandler)
                        }

                        it("should call the stacked handler with the activity") {
                            expect(stackedHandler.latestHandleActivityParameters?.activity) === activity
                        }

                        it("should call the stacked handler ignoring itself") {
                            expect(stackedHandler.latestHandleActivityParameters?.ignoring) === activityHandler
                        }

                        it("should call the child handler with the activity") {
                            expect(childHandler.latestHandleActivityParameters?.activity) === activity
                        }

                        it("should call the child handler ignoring itself") {
                            expect(childHandler.latestHandleActivityParameters?.ignoring) === activityHandler
                        }

                        it("should not ask the parent to handle activity") {
                            expect(parentHandler.latestHandleActivityParameters).to(beNil())
                        }

                        it("should return `nil`") {
                            expect(result).to(beNil())
                        }
                    }
                }
            }

            context("with a stacked handler added via stack(activityHandler:heldOnTo:) that is held on to strongly") {
                var stackedHandler: ActivityHandler!

                beforeEach {
                    stackedHandler = ActivityHandler()
                    activityHandler.stack(stackedHandler, heldOnTo: .strongly)
                }

                it("should set the parent of the stacked hanlder to itself") {
                    expect(stackedHandler.parent) === activityHandler
                }

                it("should stack the handler") {
                    expect(activityHandler.stackedHandler) === stackedHandler
                }

                context("when all other references to the stacked handler have been set to `nil`") {
                    beforeEach {
                        stackedHandler = nil
                    }

                    it("should have a stacked handler") {
                        expect(activityHandler.stackedHandler).toNot(beNil())
                    }
                }

                context("then removed via removeStackedHandler()") {
                    beforeEach {
                        activityHandler.removeStackedHandler()
                    }

                    it("should set the parent of the stacked handler to nil") {
                        expect(stackedHandler.parent).to(beNil())
                    }

                    it("should not have a stacked handler") {
                        expect(activityHandler.stackedHandler).to(beNil())
                    }
                }

                context("then removed via remove(_:)") {
                    beforeEach {
                        activityHandler.remove(stackedHandler)
                    }

                    it("should set the parent of the stacked handler to nil") {
                        expect(stackedHandler.parent).to(beNil())
                    }

                    it("should not have a stacked handler") {
                        expect(activityHandler.stackedHandler).to(beNil())
                    }
                }
            }

            context("with a stacked handler added via stack(activityHandler:heldOnTo:) that is held on to weakly") {
                var stackedHandler: ActivityHandler!

                beforeEach {
                    stackedHandler = ActivityHandler()
                    activityHandler.stack(stackedHandler, heldOnTo: .weakly)
                }

                it("should set the parent of the stacked handler to itself") {
                    expect(stackedHandler.parent) === activityHandler
                }

                it("should stack the handler") {
                    expect(activityHandler.stackedHandler) === stackedHandler
                }

                context("when all other references to the stacked handler have been set to `nil`") {
                    beforeEach {
                        stackedHandler = nil
                    }

                    it("should not have a stacked handler") {
                        expect(activityHandler.stackedHandler).to(beNil())
                    }
                }

                context("then removed via removeStackedHandler()") {
                    beforeEach {
                        activityHandler.removeStackedHandler()
                    }

                    it("should set the parent of the stacked handler to nil") {
                        expect(stackedHandler.parent).to(beNil())
                    }

                    it("should not have a stacked handler") {
                        expect(activityHandler.stackedHandler).to(beNil())
                    }
                }

                context("then removed via remove(_:)") {
                    beforeEach {
                        activityHandler.remove(stackedHandler)
                    }

                    it("should set the parent of the stacked handler to nil") {
                        expect(stackedHandler.parent).to(beNil())
                    }

                    it("should not have a stacked handler") {
                        expect(activityHandler.stackedHandler).to(beNil())
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
        }
    }

}
