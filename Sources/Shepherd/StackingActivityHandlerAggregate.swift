import Foundation

/**
 An activity handler that supports stacking, allowing for a handler to be pushed on to the stack.
 
 The stacked handler takes a higher priority than children and the parent when trying to handle an activity.
 */
open class StackingActivityHandlerAggregate: ActivityHandlerAggregate {

    private var _stackedHandler: ObjectStorage<ActivityHandler>?

    /// The handler that has been pushed
    public var stackedHandler: ActivityHandler? {
        return _stackedHandler?.object
    }

    /// Create an activity handler aggregate that supports stacking.
    public override init() {}

    /**
     Stacks the activity handler, holding on to it strongly or weakly. The stacked handler will be queried first when
     trying to handle an activity.

     - Parameter stackedHandler: The activity hander the stack on top of this activity handler
     - Parameter storageOption: How to store the activity handler, weakly or strongly.
     */
    open func stack(activityHandler stackedHandler: ActivityHandler, heldOnTo storageOption: StorageOption) {
        removeStackedHandler()

        _stackedHandler = storageOption.store(stackedHandler)
        stackedHandler.parent = self
    }

    /**
     Removes the stacked handler, resetting the parent to `nil`
     */
    open func removeStackedHandler() {
        stackedHandler?.parent = nil
        _stackedHandler = nil
    }

    /**
     Attempts to handle the provided activity by asking the stacked handler to handle the activity. If the stack handler
     cannot handle the activity the children will be asked to handle the activity. If none of the children handle the
     activity the parent will be asked to handle it.

     - Parameter activity: The activity to be handled.
     - Parameter ignoring: An optional activity handler that should be ignored. The only valid value is the stacked
                           hander, one of the children, the parent, or `nil`.
     - Returns: The handler that handled the activity, or `nil` if the activity was not handled.
     */
    @discardableResult
    open override func handle(activity: NSUserActivity, ignoring: ActivityHandler? = nil) -> ActivityHandler? {
        if let stackedHandler = stackedHandler, stackedHandler !== ignoring {
            if let handler = stackedHandler.handle(activity: activity, ignoring: self) {
                return handler
            }
        }

        return super.handle(activity: activity, ignoring: ignoring)
    }

}
