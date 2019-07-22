import Foundation

open class ActivityHandlerAggregate: ActivityHandler {

    public private(set) var children: [ActivityHandler] = []

    public override init() {}

    /**
     Adds the activity handler to the array of children that will be queried when attempting to handle
     an activity. It will also set the parent to this aggregate.
     */
    open func append(_ child: ActivityHandler) {
        children.append(child)
        child.parent = self
    }

    /**
     Removes the activity handler from the array of children that will be queried when attempting to handle
     an activity. It will also set the parent to `nil`
     */
    open func remove(_ child: ActivityHandler) {
        children.removeAll(where: { $0 === child })
        child.parent = nil
    }

    /**
     Attempts to handle the provided activity by asking children to handle the activity. If none
     of the children can handle the activity the parent will also be queried.

     - Parameter activity: The activity to be handled
     - Parameter ignoring: An optional activity handler that should be ignored while traversing
     - Returns: The handler that handled the activity, or `nil` if the activity was not handled
     */
    @discardableResult
    open override func handle(activity: NSUserActivity, ignoring: ActivityHandler? = nil) -> ActivityHandler? {
        for child in self.children where child !== ignoring {
            if let handler = child.handle(activity: activity, ignoring: self) {
                return handler
            }
        }

        return super.handle(activity: activity, ignoring: ignoring)
    }

}
