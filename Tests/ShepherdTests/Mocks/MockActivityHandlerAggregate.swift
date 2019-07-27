import Foundation
import Shepherd

class MockActivityHandlerAggregate: ActivityHandlerAggregate {

    private(set) var latestHandleActivityParameters: (activity: NSUserActivity, ignoring: ActivityHandler?)?

    override func handle(activity: NSUserActivity, ignoring: ActivityHandler? = nil) -> ActivityHandler? {
        latestHandleActivityParameters = (activity, ignoring)

        return super.handle(activity: activity, ignoring: ignoring)
    }

}
