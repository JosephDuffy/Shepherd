import Foundation

/**
 An object that can handle zero or more kinds of `NSUserActivity`s.

 By default this class with not handle any activities itself.
 */
open class ActivityHandler {

    /// The immediate parent. This will be set automatically by the parent.
    open weak var parent: ActivityHandlerAggregate?

    /// Create an activity handler.
    public init() {}

    /**
     Attempts to handle the provided activity. If the activity cannot be handled it will be ask the parent to handle
     the activity, unless the `ignoring` parameter is set to parent.

     Subclasses should override this function and handle any activities that can be handled, in which case `self` should
     be returned. If the activity should not be handled further return `nil`, otherwise return the result of a call to
     `super`.

     - parameter activity: The activity to be handled.
     - parameter ignoring: An optional activity handler to ignore. The only valid values are the parent and `nil`.
     - returns: The activity handler that handled the activity, or `nil` if it was not handled.
     */
    @discardableResult
    open func handle(activity: NSUserActivity, ignoring: ActivityHandler? = nil) -> ActivityHandler? {
        guard parent !== ignoring else { return nil }
        return parent?.handle(activity: activity, ignoring: self)
    }

}
