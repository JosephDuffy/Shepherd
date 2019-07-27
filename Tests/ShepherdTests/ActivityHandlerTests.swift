import Foundation
import Quick
import Nimble
@testable import Shepherd

final class ActivityHandlerTests: QuickSpec {

    override func spec() {
        describe("ActivityHandler") {
            var activityHandler: ActivityHandler!

            beforeEach {
                activityHandler = ActivityHandler()
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
