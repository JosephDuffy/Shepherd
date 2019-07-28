import Quick
import Nimble
@testable import Shepherd

final class ActivityHandlerAncestorsTests: QuickSpec {

    override func spec() {
        describe("ActivityHandler+Ancestors") {
            var activityHander: ActivityHandler!

            beforeEach {
                activityHander = ActivityHandler()
            }

            context("with 0 parents") {
                context("an array initialised with the `ancestors` property") {
                    var ancestors: [ActivityHandlerAggregate]!

                    beforeEach {
                        ancestors = Array(activityHander.ancestors)
                    }

                    it("should be emtpy") {
                        expect(ancestors.isEmpty) == true
                    }
                }
            }

            context("with 3 parents") {
                var parent1: ActivityHandlerAggregate!
                var parent2: ActivityHandlerAggregate!
                var parent3: ActivityHandlerAggregate!

                beforeEach {
                    parent1 = ActivityHandlerAggregate()
                    parent2 = ActivityHandlerAggregate()
                    parent3 = ActivityHandlerAggregate()
                    activityHander.parent = parent1
                    parent1.parent = parent2
                    parent2.parent = parent3
                }

                context("an array initialised with the `ancestors` property") {
                    var ancestors: [ActivityHandlerAggregate]!

                    beforeEach {
                        ancestors = Array(activityHander.ancestors)
                    }

                    it("should have a count of 3") {
                        expect(ancestors.count) == 3
                    }

                    it("should start with the immediate parent") {
                        expect(ancestors.first) === activityHander.parent
                    }

                    it("should end with the furthest away ancestor") {
                        expect(ancestors.last) === parent3
                    }
                }
            }
        }
    }

}
