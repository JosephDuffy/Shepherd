import Foundation

open class ActivityHandler {

    open weak var parent: ActivityHandlerAggregate?

    /**
     Attempts to handle the provided activity. Subclasses should override this function and handle
     any activities that can be handled, in which case `self` should be returned. If the activity should
     not be handled further return `nil`, otherwise return the result of a call to `super`.

     - parameter activity: The activity to be handled
     - returns: A bool indicating if a handler handled the activity
     */
    @discardableResult
    open func handle(activity: NSUserActivity, ignoring: ActivityHandler? = nil) -> ActivityHandler? {
        guard parent !== ignoring else { return nil }
        return parent?.handle(activity: activity, ignoring: self)
    }

}
