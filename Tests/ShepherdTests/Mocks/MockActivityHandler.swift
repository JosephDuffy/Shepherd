import Foundation
import Shepherd

class MockActivityHandler: ActivityHandler {

    private(set) var latestHandleActivityParameters: (activity: NSUserActivity, ignoring: ActivityHandler?)?

    var activityToHandle: NSUserActivity?

    override func handle(activity: NSUserActivity, ignoring: ActivityHandler? = nil) -> ActivityHandler? {
        latestHandleActivityParameters = (activity, ignoring)

        if activity == activityToHandle {
            return self
        }

        return super.handle(activity: activity, ignoring: ignoring)
    }

}
